defmodule Aruspex do
  import Enum, only: [reduce: 3]
  import Aruspex.State

  @moduledoc """
  Aruspex Solver

  Aruspex is a generic, mostly JSR-331 compliant cp solver which can solve
  typical linear constraint problems.
  """

  defdelegate [
    start_link(),
    start_link(options),
    stop(pid),
    variable(pid, v, d),
    post(pid, c),
    post(pid, v, c),
    find_solution(pid),
    set_search_strategy(pid, strategy),
    get_terms(pid)
  ], to: __MODULE__.Server

  def compute_cost state do
    zero_cost(state)
    |> compute_cost(state.constraints)
  end

  defp compute_cost state, [], acc do
    put_in state.cost, acc
  end

  defp compute_cost state, [{variables, constraint}|t], acc \\ 0  do
    cost = apply constraint, value_of(state, variables)
    compute_cost(state, t, cost + acc)
  end

  defp zero_cost state do
    put_in(state.cost, 0)
    |> put_cost terms(state), 0
  end

  defp put_cost state, [], _cost do
    state
  end

  defp put_cost state, [h|t], cost do
    put_cost(state, h, cost)
    |> put_cost(t, cost)
  end

  defp put_cost state, v, cost do
    put_in(state.variables[v].cost, cost)
  end
end
