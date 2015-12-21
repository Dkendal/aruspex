defmodule Aruspex.Strategy.SimulatedAnnealing do
  alias Aruspex.State
  alias Aruspex.Var
  import Enum, only: [reduce: 3]
  import Aruspex.State, only: [compute_cost: 1]
  use Aruspex.Strategy
  use BackPipe

  @moduledoc """
  Implementation or simulated annealing strategy for Aruspex solver.

  Good at finding okay, solutions quickly in large problem spaces - not so good
  at finding optimal solutions.

  More info on [wikipedia](https://en.wikipedia.org/wiki/Simulated_annealing).

  Pseudo-code algorithm:
      Let s = s0
      For k = 0 through kmax (exclusive):
      T ← temperature(k/kmax)
      Pick a random neighbour, snew ← neighbour(s)
      If P(E(s), E(snew), T) > random(0, 1), move to the new state:
      s ← snew
      Output: the final state s

      s0 :: initial state
      kmax :: maximum steps
  """
  @initial_temp 1
  @k_max 1000
  @cooling_constant 40

  def label(state) do
    restart(state)
    |> compute_cost
    |> do_sa(0)
  end

  def do_sa(state, @k_max),
    do: state

  def do_sa(s, k) do
    if State.satisfied?(s) do
      s
    else
      t = temperature(k/@k_max)
      s_prime = compute_cost neighbour s

      if acceptance_probability(s.cost, s_prime.cost, t) > :rand.uniform do
        do_sa(s_prime, k+1)
      else
        do_sa(s, k+1)
      end
    end
  end

  defp restart(state) do
    sample = fn var ->
      var
      |> Var.domain
      |> Enum.random
      <|> Var.bind(var)
    end

    sample_all = fn(key, state) ->
      State.update_var(state, key, sample)
    end

    state
    |> State.terms
    |> reduce(state, sample_all)
  end

  defp neighbour(state) do
    try do
      state
      |> State.terms
      |> Enum.random
      <|> decide(state)
    rescue
      Enum.EmptyError -> restart(state)
    end
  end

  defp decide(state, name) do
    state
    |> State.update_var(name, fn var ->
      var
      |> Var.domain
      |> Enum.reject(& &1 == Var.binding(var))
      |> Enum.random
      <|> Var.bind(var)
    end)
  end

  defp temperature(n) do
    @initial_temp * :math.exp(@cooling_constant * -n)
  end

  defp acceptance_probability(e, e_p, _temp) when e > e_p, do: 1
  defp acceptance_probability(e, e_p, temp) do
    :math.exp(-(e_p - e)/temp)
  end
end
