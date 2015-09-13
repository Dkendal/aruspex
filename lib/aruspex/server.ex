defmodule Aruspex.Server do
  use ExActor.GenServer
  use PatternTap
  use Aruspex.Constraint

  alias Aruspex.State
  alias Aruspex.Var
  alias Aruspex

  import State

  @type var :: any
  @type domain :: Enum.t
  @type strategy :: Aruspex.Strategy.t

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
  @spec post(pid, [var], Aruspex.Constraint.t) :: :ok
  defcall post(v, c), state: state, when: is_function(c, length(v)) do
    update_in(state.constraints, & [{v,c}|&1])
    |> set_and_reply :ok
  end

  def post(pid, constraint(variables: v, function: c)) do
    post pid, v, c
  end

  @doc """
  Attemps to find the first solution to the problem. Uses the default search if
  one was not defined by set_search_strategy. Returns the solution or raises an
  error if non is found or the search times out.
  """
  @spec find_solution(pid) :: [{var, any}]
  defcall find_solution(), state: state do
    state.options.strategy.label(state)
    |> case do
      nil ->
        raise Aruspex.Strategy.InvalidResultError, module: state.options.strategy
      s -> s
    end
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
end