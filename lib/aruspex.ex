defmodule Aruspex do
  import Enum, only: [reduce: 3]

  use ExActor.GenServer
  use PatternTap

  defmodule Var do
    defstruct binding: nil, constraints: [], domain: []
    @type constraint :: ((any, any) -> boolean)
    @type t :: %Var{binding: any, domain: Enum.t }
  end

  defmodule State do
    defstruct constraints: [], variables: %{}
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

  defcast constraint(variables, constraint_fn), state: state do
    fn(state) ->
      variables
      |> Enum.map(&state.variables[&1].binding)
      |> tap(v ~> apply(constraint_fn, v))
    end
    |> tap(c ~> update_in(state.constraints, fn(t) -> [c|t] end))
    |> new_state
  end

  defcall label(), state: state, timeout: :infinity do
    reply Aruspex.SimulatedAnnealing.label(state)
  end
end
