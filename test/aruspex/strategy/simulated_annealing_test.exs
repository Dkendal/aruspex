Code.require_file("./test/aruspex/strategy_test.exs")
defmodule Aruspex.Strategy.SimulatedAnnealingTest do
  use ExUnit.Case, async: true
  use Aruspex.Constraint

  use Aruspex.StrategyTest,
    strategy: Aruspex.Strategy.SimulatedAnnealing
end
