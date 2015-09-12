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

  defimpl Inspect, for: __MODULE__ do
    import Inspect.Algebra

    def inspect state, opts do
      concat ["#Aruspex.State<",to_doc(state.variables, opts), ">"]
    end
  end
end
