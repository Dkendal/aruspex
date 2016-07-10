defmodule Aruspex.Strategy.SimulatedAnnealingTest do
  use Aruspex.Case

  test "solves the map colouring problem" do
    [result] = Examples.MapColouring.new
                |> Aruspex.Strategy.SimulatedAnnealing.set_strategy()
                |> Enum.take(1)

    assert result.complete?
    assert result.valid?
  end

  test "solves the four queens problem" do
    [result] = Examples.FourQueens.new
                |> Aruspex.Strategy.SimulatedAnnealing.set_strategy()
                |> Enum.take(1)

    assert result.valid?
    assert result.complete?
  end
end
