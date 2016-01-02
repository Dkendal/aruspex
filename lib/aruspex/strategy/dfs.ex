defmodule Aruspex.Strategy.Dfs do
  @behaviour Aruspex.Strategy

  defstruct problem: nil, timeout: 5000

  def set_strategy(problem, opts \\ []) do
    opts = Enum.into opts, %{}
    struct __MODULE__, Map.put(opts, :problem, problem)
  end
end

defimpl Enumerable, for: Aruspex.Strategy.Dfs do
  alias Aruspex.Evaluation
  import Aruspex.Problem
  import Evaluation

  def member?(_, _), do: {:error, __MODULE__}
  def count(_), do: {:error, __MODULE__}

  def reduce(s, {:cont, acc}, fun) do
    start(s)
    do_reduce(s, {:cont, acc}, fun)
  end

  def do_reduce(_s, {:halt, acc}, _fun), do: {:halted, acc}

  def do_reduce(s, {:cont, acc}, fun) do
    receive do
      {:cont, solution} ->
        do_reduce(s, fun.(solution, acc), fun)

      :done ->
        {:done, acc}

    after s.timeout ->
      raise "sup"
    end
  end

  def start(strategy) do
    caller = self
    spawn_link fn ->
      try do
      do_search(strategy, caller)
      catch
      ArgumentError ->
        Proccess.exit(self, :normal)
      end
    end
  end

  def do_search(%{problem: g}, caller) do
    eval = %Evaluation{problem: g}
    g
    |> labeled_variables(order: :most_constrained)
    |> do_dfs(eval, caller)
    send caller, :done
  end

  def do_dfs([{var, domain} | t], eval, caller) do
    Enum.each domain, fn value ->
      eval = put_in(eval.binding[var], value)
              |> evaluation

      if eval.valid? do
        do_dfs(t, eval, caller)
      end
    end
  end

  # fully bound
  def do_dfs([], eval, caller) do
    if eval.valid? do
      send caller, {:cont, eval}
    end
  end
end
