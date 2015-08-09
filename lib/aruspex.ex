defmodule Aruspex do
  use GenServer
  import GenServer
  import Enum, only: [reduce: 3]

  defmodule Var do
    defstruct binding: nil, constraints: [], domain: []
    @type constraint :: ((any, any) -> boolean)
    @type t :: %Var{binding: any, constraints: [constraint], domain: Enum.t }
  end

  # Client

  def new(options\\[])

  def new(options) do
    start_link(__MODULE__, %{}, options)
  end

  def variables(pid, variables) do
    pid |> cast({:variables, variables})
  end

  def domain(pid, variables, domain) do
    pid |> cast({:domain, variables, domain})
  end

  def constraint(pid, variables, constraint) do
  end

  def label(pid) do
  end

  # Callbacks
  @doc "variables/1 callback"
  def handle_cast({:variables, variables}, state) do
    new_state = reduce variables, state, fn(v, acc) ->
      put_in acc, [v], %Var{}
    end
    {:noreply, new_state}
  end

  @doc "domain/2 callback"
  def handle_cast({:domain, variables, domain}, state) do
    new_state = reduce variables, state, fn(v, acc) ->
      update_in acc, [v, :domain], domain
    end
    {:noreply, new_state}
  end
end
