defmodule Aruspex do
  use ExActor.GenServer
  import Enum, only: [reduce: 3]

  defmodule Var do
    defstruct binding: nil, constraints: [], domain: []
    @type constraint :: ((any, any) -> boolean)
    @type t :: %Var{binding: any, constraints: [constraint], domain: Enum.t }
  end

  defstart start_link, gen_server_opts: :runtime do
    initial_state %{}
  end

  defcast variables(variables), state: state do
    reduce(variables, state, &put_in(&2[&1], %Var{}))
    |> new_state
  end

  defcast domain(variables, domain), state: state do
    reduce(variables, state, &put_in(&2[&1].domain, domain))
    |> new_state
  end

  defcast constraint(variables, constraint), state: state do
    update_con = fn(variable, state) ->
      update_in state[variable].constraints, &([constraint|&1])
    end

    reduce(variables, state, update_con)
    |> new_state
  end

  def label(pid) do
  end
end
