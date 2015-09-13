defmodule Aruspex.State do
  defstruct constraints: [],
    variables: %{},
    cost: 0,
    options: %{
      strategy: Aruspex.Strategy.SimulatedAnnealing}

  def value_of state, terms do
    for x <- terms, do: state.variables[x].binding
  end

  def bound_variables state do
    for {k, v} <- state.variables, do: {k, v.binding}
  end

  def terms state do
    Dict.keys state.variables
  end

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

  defimpl Inspect, for: __MODULE__ do
    import Inspect.Algebra

    def inspect state, opts do
      concat ["#Aruspex.State<",to_doc(state.variables, opts), ">"]
    end
  end
end
