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

  @initial_temp 1
  @k_max 500
  @cooling_constant 1/1000

  def restart(state) do
    keys = Dict.keys state.variables
    reduce(keys, state, fn(key, state) ->
      value = take_random state.variables[key].domain
      put_in state.variables[key].binding, value
    end)
  end

  defp finalize(state, k, e_best) do
    labels = state.variables
              |> Dict.to_list
    |> Enum.map fn {k, v} ->
    {k , v.binding}
    end

    {labels, k, e_best}
  end

  def label(state, k\\-1, e_best\\ nil, state_best\\nil)
  def label(_state, @k_max, e_best, state_best) do
    finalize(state_best, @k_max, e_best)
  end

  def label(state, -1, nil, nil) do
    restart(state)
    |> label(0)
  end

  def label(state, k, e_best, state_best) do
    t = temperature(k/@k_max)
    candidate_state = neighbour(state)

    e = energy(state)
    e_prime = energy(candidate_state)

    {e_best_prime, state_best_prime} = if e_prime < e_best do
      {e_prime, candidate_state}
    else
      {e_best, state_best}
    end

    if e == 0 do
      finalize(state, k, 0)
    else
      if acceptance_probability(e, e_prime, t) > :rand.uniform do
        label(candidate_state, k+1, e_best_prime, state_best_prime)
      else
        label(state, k+1, e_best_prime, state_best_prime)
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

    v = state.variables[key]

    value = (v.domain -- [v.binding])
            |> take_random

    put_in state.variables[key].binding, value
  end

  def acceptance_probability(e, e_p, _temp) when e > e_p, do: 1
  def acceptance_probability(e, e_p, temp) do
    :math.exp(-(e_p - e)) / temp
  end

  # apply constraints
  defp energy(state) do
    reduce state.__constraints__, 0, fn(constraint, e) ->
      constraint.(state) + e
    end
  end

  defp take_random(list) do
    list |> Enum.shuffle |> List.first
  end
end
