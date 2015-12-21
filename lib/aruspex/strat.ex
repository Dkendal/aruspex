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

    child = spawn_link fn ->
      strat
      |> Aruspex.Strategy.do_iterator(state, caller)
    end

    Stream.repeatedly(fn ->
      receive do
        {:solution, ^child, state} ->
          state
      after 5000 ->
        nil
      end
    end)
  end
end
