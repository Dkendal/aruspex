defmodule Aruspex.State do
  alias Aruspex.Var
  alias Aruspex.Constraint
  use BackPipe

  @moduledoc """
  Defines operations on the state atom.

  These methods, and the state atom, are not intended to be interacted on
  directly inside on an application. It is recommended using the API exposed by
  Aruspex.Server instead.
  """

  @opaque t :: %__MODULE__{
    constraints: [Constraint.t],
    variables: variables,
    cost: number,
    options: options
  }

  @type options :: %{
    strategy: module
  }

 @type solution :: [{Var.name, any}]

  @type variables :: %{Var.name => Var.t}

  defstruct(
    constraints: [],
    variables: %{},
    cost: 0,
    options: %{
      strategy: Aruspex.Strategy.SimulatedAnnealing
    }
  )

  @spec bound_variables(t) :: solution
  def bound_variables state do
    for {name, var} <- get_vars(state),
      do: {name, Var.binding(var)}
  end

  @spec terms(t) :: [Var.name]
  def terms state do
    state
    |> get_vars
    |> Dict.keys
  end

  @spec find_solution(t) :: t
  def find_solution(state) do
    strat = get_strategy state
    case strat.label(state) do
      nil ->
        raise(
          Aruspex.Strategy.InvalidResultError,
          module: state.options.strategy)
      s ->
        s
    end
  end

  @spec get_var(t, Var.name) :: Var.t
  def get_var(state, name) do
    state.variables[name]
  end

  @spec set_var(t, Var.name, Var.t) :: t
  def set_var(state, name, var) do
    put_in state.variables[name], var
  end

  @spec add_constraint(t, Constraint.t) :: t
  def add_constraint(state, c) do
    update_in state.constraints, fn constraints ->
      [c|constraints]
    end
  end

  @spec update_var(t, Var.name, (Var.t -> Var.t)) :: t
  def update_var(state, name, fun) do
    update_in state.variables[name], fun
  end

  @spec get_vars(t) :: variables
  def get_vars(state) do
    state.variables
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

  @spec get_cost(State.t) :: Var.cost
  @module "Returns the cost of the current, or last executed, problem."
  def get_cost state do
    state.cost
  end

  defp set_cost(state, cost) do
    put_in state.cost, cost
  end

  defp zero_cost state do
    state
    |> get_vars
    |> Enum.reduce(state, fn
      {name, var}, state ->
        var
        |> Var.set_cost(0)
        <|> set_var(state, name)
    end)
    |> set_cost(0)
  end

  defp get_strategy(state) do
    state.options.strategy
  end

  defimpl Inspect, for: __MODULE__ do
    import Inspect.Algebra

    def inspect state, opts do
      concat ["#Aruspex.State<",to_doc(state.variables, opts), ">"]
    end
  end
end
