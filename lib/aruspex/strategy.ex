defprotocol Aruspex.Strategy do
  alias Aruspex.State
  @type t :: __MODULE__.t

  @spec do_iterator(t, State.t, pid) :: Enumerable.t
  def do_iterator(strat, state, caller)
end

defmodule Aruspex.Strat do
  def label(strat, state) do
    strat
    |> iterator(state)
    |> Enum.take(1)
    |> hd
  end

  def iterator(strat, state)
  def iterator(strat, state) do
    caller = self

    spawn_link fn ->
      strat
      |> Aruspex.Strategy.do_iterator(state, caller)
    end

    Stream.repeatedly(fn ->
      receive do
        {:solution, state} ->
          state
        {:done, state} ->
          state
      end
    end)
  end
end
