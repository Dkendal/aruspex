defmodule Aruspex.Strategy.SimulatedAnnealingTest do
  use Aruspex.Case

  test "solves the map colouring problem" do
    [result] = Examples.MapColouring.new
    |> Aruspex.Strategy.SimulatedAnnealing.set_strategy()
    |> Enum.take(1)

    Aruspex.Logger.log_stats([result])

    assert result.valid? == true
  end
end
