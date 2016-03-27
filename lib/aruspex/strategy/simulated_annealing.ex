defmodule Aruspex.Strategy.SimulatedAnnealing do
  @behaviour Aruspex.Strategy

  defstruct problem: nil,
            initial_temp: 1,
            k_max: 8000,
            cooling_constant: 40

  def set_strategy(problem, opts \\ []) do
    opts = Enum.into opts, %{}
    struct __MODULE__, Map.put(opts, :problem, problem)
  end
end

defimpl Enumerable, for: Aruspex.Strategy.SimulatedAnnealing do
  alias Aruspex.Strategy.SimulatedAnnealing, as: SA
  alias Aruspex.Evaluation
  import Aruspex.Problem
  import Evaluation
  use Aruspex.Strategy

  def reduce(%SA{} = s, {:cont, acc}, fun) do
    binding = restart s.problem
    eval = evaluation %Evaluation{problem: s.problem, binding: binding}
    do_reduce(eval, s, {:cont, acc}, fun)
  end

  def do_reduce(_, s, {:halt, acc}, fun), do: {:halted, acc}

  def do_reduce(%Evaluation{valid?: true} = e, s, {:cont, acc}, fun) do
    do_reduce bind(e, restart(s.problem)), s, fun.(e, acc), fun
  end

  def do_reduce(%Evaluation{step: k} = e, %SA{k_max: k}, {:cont, acc}, fun) do
    {:done, fun.(e, acc)}
  end

  def do_reduce(eval, s, acc, fun) do
    t = temperature(eval.step, s)

    candidate = evaluation neighbour eval

    if acceptance_probability(energy(eval), energy(candidate), t) > :rand.uniform do
      do_reduce(candidate, s, acc, fun)
    else
      eval
      |> step
      |> do_reduce(s, acc, fun)
    end
  end

  def energy(%{total_violations: v, total_cost: c}) do
    v * 100_000_000 + c
  end

  def neighbour(evaluation) do
    problem = evaluation.problem
    v = Enum.random variables(problem)
    x = variable(problem, v) |> elem(1) |> Enum.random

    update_in evaluation.binding, fn b ->
      put_in b[v], x
    end
  end

  defp temperature(k, s) do
    n = k / s.k_max
    s.initial_temp * :math.exp(s.cooling_constant * -n)
  end

  defp acceptance_probability(e, e_p, _temp) when e > e_p, do: 1
  defp acceptance_probability(e, e_p, temp) do
    :math.exp(-(e_p - e)/temp)
  end

  def restart(csp() = p) do
    labeled_variables(p)
    |> Enum.map(fn {v, d} ->
      {v, Enum.random(d)}
    end)
  end
end
