alias Aruspex.Evaluation
import Aruspex.Problem
import Evaluation

defmodule Aruspex.Strategy.Dfs do
  @behaviour Aruspex.Strategy

  defstruct problem: nil, timeout: 5000

  def set_strategy(problem, opts \\ []) do
    opts = Enum.into opts, %{}
    struct __MODULE__, Map.put(opts, :problem, problem)
  end
end

defimpl Enumerable, for: Aruspex.Strategy.Dfs do
  use Aruspex.Strategy

  def reduce(s, {:cont, acc}, fun) do
    eval = %Evaluation{problem: s.problem}

    s.problem
    |> labeled_variables(order: :most_constrained)
    |> do_reduce(eval, acc, fun)
  end

  # fully bound
  def do_reduce([], eval, acc, fun) do
    (if eval.valid?, do: fun.(eval, acc), else: {:cont, acc})
    |> case do
      # fun.(eval, acc) may return {:cont, acc}, so it needs to be caught
      {:cont, acc} ->
        {[], acc}
      x ->
        x
    end
  end

  def do_reduce([{var, domain} | t], eval, acc, fun) do
    Enum.flat_map_reduce domain, acc, fn value, acc ->
      eval =
        put_in(eval.binding[var], value)
        |> evaluation

      if eval.valid?, do: do_reduce(t, eval, acc, fun), else: {[], acc}
    end
  end
end
