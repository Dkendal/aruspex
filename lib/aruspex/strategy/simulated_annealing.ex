defmodule Aruspex.Strategy.SimulatedAnnealing do
  import Enum, only: [reduce: 3]
  import Aruspex, only: [compute_cost: 1]
  use PatternTap

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
  @behaviour Aruspex.Strategy
  @initial_temp 1
  @k_max 1000
  @cooling_constant 40

  def label(state, k\\-1)

  def label(state, -1) do
    restart(state)
    |> compute_cost
    |> label(0)
  end

  def label(%{cost: 0} = s, _), do: s
  def label(s, @k_max), do: s

  def label(s, k) do
    t = temperature(k/@k_max)
    s_prime = compute_cost neighbour s

    if acceptance_probability(s.cost, s_prime.cost, t) > :rand.uniform do
      label(s_prime, k+1)
    else
      label(s, k+1)
    end
  end

  defp restart(state) do
    keys = Dict.keys state.variables
    reduce(keys, state, fn(key, state) ->
      value = take_random state.variables[key].domain
      put_in state.variables[key].binding, value
    end)
  end

  defp neighbour(state) do
    key = state.variables
          |> Dict.to_list
          |> Enum.reject(fn {_,v} -> v.cost == 0 end)
          |> Dict.keys
          |> take_random
    decide(state, key)
  end

  defp decide(state, nil),
    do: raise "Couldn't yield a neighbor state, key was nil"
  defp decide(state, key) do
    state.variables[key]
    |> tap(v ~> v.domain -- [v.binding])
    |> take_random
    |> tap(v ~> put_in state.variables[key].binding, v)
  end

  defp temperature(n) do
    @initial_temp * :math.exp(@cooling_constant * -n)
  end

  defp acceptance_probability(e, e_p, _temp) when e > e_p, do: 1
  defp acceptance_probability(e, e_p, temp) do
    :math.exp(-(e_p - e)/temp)
  end

  defp take_random(list) do
    list
    |> Enum.shuffle
    |> List.first
  end
end
