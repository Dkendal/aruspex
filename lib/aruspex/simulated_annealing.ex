# https://en.wikipedia.org/wiki/Simulated_annealing
# Let s = s0
# For k = 0 through kmax (exclusive):
#     T ← temperature(k/kmax)
#     Pick a random neighbour, snew ← neighbour(s)
#     If P(E(s), E(snew), T) > random(0, 1), move to the new state:
#         s ← snew
# Output: the final state s

# s0 :: initial state
# kmax :: maximum steps
defmodule Aruspex.SimulatedAnnealing do
  import Enum, only: [reduce: 3]
  import Aruspex, only: [compute_cost: 1]

  use PatternTap

  @initial_temp 1
  @k_max 500
  @cooling_constant 1/100

  def restart(state) do
    keys = Dict.keys state.variables
    reduce(keys, state, fn(key, state) ->
      value = take_random state.variables[key].domain
      put_in state.variables[key].binding, value
    end)
  end

  def label(state, k\\-1)

  def label(s, @k_max), do: s

  def label(state, -1) do
    restart(state)
    |> compute_cost
    |> label(0)
  end

  def label(s, k) do
    t = temperature(k/@k_max)

    s_prime = compute_cost neighbour s

    if s.cost == 0 do
      s
    else
      if acceptance_probability(s.cost, s_prime.cost, t) > :rand.uniform do
        label(s_prime, k+1)
      else
        label(s, k+1)
      end
    end
  end

  def temperature(n) do
    @initial_temp * :math.exp(@cooling_constant * -n)
  end

  def neighbour(state) do
    key = state.variables
          |> Dict.keys
          |> take_random

    state.variables[key]
    |> tap(v ~> v.domain -- [v.binding])
    |> take_random
    |> tap(v ~> put_in state.variables[key].binding, v)
  end

  def acceptance_probability(e, e_p, _temp) when e > e_p, do: 1
  def acceptance_probability(e, e_p, temp) do
    :math.exp(-(e_p - e))
  end

  defp take_random(list) do
    list
    |> Enum.shuffle
    |> List.first
  end
end
