defmodule Aruspex do
  import Enum, only: [reduce: 3]

  use ExActor.GenServer
  use PatternTap
  use Exyz

  defmodule Var do
    defstruct binding: nil, constraints: [], domain: [], cost: 0
    @type constraint :: ((any, any) -> boolean)
    @type t :: %Var{binding: any, domain: Enum.t }
  end

  defmodule State do
    defstruct constraints: [], variables: %{}, cost: 0
  end

  defstart start_link, gen_server_opts: :runtime do
    initial_state %State{}
  end

  defcast variables(variables), state: state do
    reduce(variables, state, &put_in(&2.variables[&1], %Var{}))
    |> new_state
  end

  defcast domain(variables, domain), state: state do
    reduce(variables, state, &put_in(&2.variables[&1].domain, domain))
    |> new_state
  end

  # v: [variable], c: constraint
  defcast constraint(v, c), state: state do
    update_in(state.constraints, fn constraints ->
      [{v, c}| constraints]
    end)
    |> new_state
  end

  defcast label(), state: state, from: from, timeout: :infinity do
    Aruspex.SimulatedAnnealing.label(state)
    |> new_state
  end

  defcall get_state(), state: state do
    reply state
  end

  def compute_cost state do
    zero_cost(state)
    |> compute_cost(state.constraints)
  end

  defp compute_cost state, [] do
    state
  end

  defp compute_cost state, [{variables, constraint}|t] do
    cost = apply constraint, value_of(state, variables)
    add_cost(state, variables, cost)
    |> add_total_cost(cost)
    |> compute_cost(t)
  end

  def value_of state, terms do
    for x <- terms, do: state.variables[x].binding
  end

  def terms state do
    Dict.keys state.variables
  end

  defp add_total_cost state, cost do
    update_in state.cost, &(&1 + cost)
  end

  defp zero_cost state do
    put_in(state.cost, 0)
    |> put_cost terms(state), 0
  end

  defp add_cost state, [], _cost do
    state
  end

  defp add_cost state, [h|t], cost do
    add_cost(state, h, cost)
    |> add_cost(t, cost)
  end

  defp add_cost state, v, cost do
    update_in(state.variables[v].cost, &(&1 + cost))
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
