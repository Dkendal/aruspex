defmodule Aruspex do
  import Enum, only: [reduce: 3]
  use ExActor.GenServer
  use PatternTap

  @type var :: any
  @type cost :: number
  @type domain :: Enum.t
  @type strategy :: Aruspex.Strategy.t
  @type constraint :: (... -> cost)

  defmodule Var do
    @type t :: %Var{binding: any, domain: Aruspex.domain }
    defstruct binding: nil, domain: [], cost: 0
  end

  defmodule State do
    defstruct constraints: [], variables: %{}, cost: 0,
      options: %{strategy: Aruspex.Strategy.SimulatedAnnealing}
  end

  @spec start_link(Map.t) :: {:ok, pid}
  defstart start_link, gen_server_opts: :runtime do
    initial_state %State{}
  end

  @doc "Stops the server."
  @spec stop(pid) :: :ok
  defcast stop, state: state do
    stop_server :normal
  end

  @doc """
  Adds a constrained variable v, with domain d, to the problem.
  """
  @spec variable(pid, var, domain) :: var
  defcall variable(v, d), state: state do
    put_in(state.variables[v], %Var{domain: d})
    |> set_and_reply v
  end

  @doc """
  Defines a linear constraint on all variables v, c must a function with an
  arity that matches the number of variables.
  """
  @spec post(pid, [var], constraint) :: :ok
  defcall post(v, c), state: state, when: is_function(c, length(v)) do
    update_in(state.constraints, & [{v,c}|&1])
    |> set_and_reply :ok
  end

  @doc """
  Attemps to find the first solution to the problem. Uses the default search
  if one was not defined by set_search_strategy. Returns the solution or raises an error if non is found or the search times out.
  """
  @spec find_solution(pid) :: [{var, any}]
  defcall find_solution(), state: state do
    state.options.strategy.label(state)
    |> tap s ~> set_and_reply s, bound_variables(s)
  end

  @doc "Sets the strategy to be used by the searcher"
  @spec set_search_strategy(pid, strategy) :: :ok
  defcall set_search_strategy(strategy), state: state do
    put_in(state.options.strategy, strategy)
    |> set_and_reply :ok
  end

  defcall get_terms(), state: state do
    state
    |> terms
    |> reply
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

  defp bound_variables state do
    for {k, v} <- state.variables, do: {k, v.binding}
  end
end
