defmodule Aruspex do
  import Enum, only: [reduce: 3]
  use ExActor.GenServer
  alias Aruspex.SimulatedAnnealing

  defmodule Var do
    defstruct binding: nil, constraints: [], domain: []
    @type constraint :: ((any, any) -> boolean)
    @type t :: %Var{binding: any, constraints: [constraint], domain: Enum.t }
  end

  defstart start_link, gen_server_opts: :runtime do
    initial_state %{__constraints__: [], variables: %{}}
  end

  defcast variables(variables), state: state do
    reduce(variables, state, &put_in(&2.variables[&1], %Var{}))
    |> new_state
  end

  defcast domain(variables, domain), state: state do
    reduce(variables, state, &put_in(&2.variables[&1].domain, domain))
    |> new_state
  end

  defcast constraint(variables, constraint), state: state do
    c = fn(state) ->
      variables
      |> Enum.map(&state.variables[&1].binding)
      |> (&apply(constraint, &1)).()
    end

    update_in(state.__constraints__, &([c|&1]))
    |> new_state
  end

  defcall label(), state: state, timeout: :infinity do
    reply SimulatedAnnealing.label(state)
  end
end
