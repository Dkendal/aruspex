defmodule Aruspex.Strategy.Dfs do
  alias Aruspex.State
  alias Aruspex.Var
  use Aruspex.Strategy

  def label(state) do
    :ok = state
    |> State.get_vars
    |> Enum.to_list
    |> do_dfs(state)

    receive do
      state -> state
    end
  end

  def do_dfs([], state) do
    if State.satisfied?(state) do
      send self, state
    else
      :continue
    end
  end

  def do_dfs([{name, v}|t], state) do
    v
    |> Var.domain
    |> Enum.each(fn x ->
      if State.complete?(state) do
        state
      else
        state =
          state
          |> State.update_var(name, & Var.bind(&1, x))
          |> State.compute_cost

        if State.valid?(state) do
          do_dfs(t, state)
        end
      end
    end)
  end
end
