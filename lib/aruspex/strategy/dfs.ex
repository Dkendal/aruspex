defmodule Aruspex.Strategy.Dfs do
  alias Aruspex.State
  alias Aruspex.Var
  import Aruspex.Strat.Helpers

  defstruct []

  def do_iterator(_strat, state, caller) do
    state
    |> State.get_vars
    |> Enum.to_list
    |> do_dfs(state, caller)
  end

  def do_dfs([], state, caller) do
    if State.satisfied?(state) do
      found_solution(state, caller)
    end
  end

  def do_dfs([{name, v}|t], state, caller) do
    for value <- Var.domain(v) do
      state =
        state
        |> State.update_var(name, &Var.bind(&1, value))
        |> State.compute_cost

      if State.valid?(state) do
        do_dfs(t, state, caller)
      end
    end
  end

  defimpl Aruspex.Strategy, for: __MODULE__ do
    def do_iterator(strat, state, caller) do
      Aruspex.Strategy.Dfs.do_iterator(strat, state, caller)
    end
  end
end
