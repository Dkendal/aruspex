defmodule Aruspex.Strategy.Dfs do
  alias Aruspex.State
  alias Aruspex.Var
  use Aruspex.Strategy

  def label(state) do
    state
    |> iterator
    |> Enum.take(1)
    |> hd
  end

  def iterator(state, opts \\ [timeout: 5000])
  def iterator(state, timeout: timeout) do
    vars =
      state
      |> State.get_vars
      |> Enum.to_list

    child = spawn_link(__MODULE__, :do_dfs, [vars, state, self])

    Stream.repeatedly(fn ->
      receive do
        {^child, state} ->
          state
      after timeout ->
        nil
      end
    end)
  end

  def do_dfs([], state, caller) do
    if State.satisfied?(state) do
      send caller, {self, state}
    end
  end

  def do_dfs([{name, v}|t], state, caller) do
    v
    |> Var.domain
    |> Enum.each(fn x ->
      state =
        state
        |> State.update_var(name, & Var.bind(&1, x))
        |> State.compute_cost

      if State.valid?(state) do
        do_dfs(t, state, caller)
      end
    end)
  end
end
