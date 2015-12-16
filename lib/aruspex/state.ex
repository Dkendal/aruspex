defmodule Aruspex.State do
  alias Aruspex.Var
  alias Aruspex.Constraint

  @moduledoc """
  Defines operations on the state atom.

  These methods, and the state atom, are not intended to be interacted on
  directly inside on an application. It is recommended using the API exposed by
  Aruspex.Server instead.
  """

  @opaque t :: %__MODULE__{
    constraints: [Constraint.t],
    variables: [Var.t],
    cost: number,
    options: options
  }

  @type options :: %{
    strategy: module
  }

  defstruct(
    constraints: [],
    variables: %{},
    cost: 0,
    options: %{
      strategy: Aruspex.Strategy.SimulatedAnnealing
    }
  )

  @spec value_of(t, [Literals]) :: any
  def value_of state, terms do
    for x <- terms, do: state.variables[x].binding
  end

  @spec bound_variables(t) :: [{Literals, any}]
  def bound_variables state do
    for {k, v} <- state.variables, do: {k, v.binding}
  end

  @spec terms(t) :: [Literals]
  def terms state do
    Dict.keys state.variables
  end

  @spec get_var(t, Literals) :: Var.t
  def get_var(state, v) do
    state.variables[v]
  end

  @spec compute_cost(t) :: t
  @spec compute_cost(t, [Constraint.t], any) :: t
  def compute_cost state do
    zero_cost(state)
    |> compute_cost(state.constraints, 0)
  end

  def compute_cost state, [], acc do
    put_in state.cost, acc
  end

  def compute_cost state, [constraint|t], acc do
    binding = bound_variables(state)
    cost = Constraint.test_constraint(constraint, binding)
    compute_cost(state, t, cost + acc)
  end

  @spec get_cost(State.t) :: number
  @module "Returns the cost of the current, or last executed, problem."
  def get_cost state do
    state.cost
  end

  defp zero_cost state do
    put_in(state.cost, 0)
    |> put_cost(terms(state), 0)
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
