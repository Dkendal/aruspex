defmodule Aruspex.Strategy.SimulatedAnnealingTest do
  use ExUnit.Case, async: true
  use Aruspex.Constraint
  alias Aruspex, as: A

  @tag timeout: 100000
  test "4 queens" do
    n = 4
    strategy = :simulated_annealing

    {:ok, pid} = A.start_link

    for x <- 1..n, do:
    A.variable(pid, x, (for y <- 1..n, do: {x, y}))
    A.set_strategy pid, Aruspex.Strategy.SimulatedAnnealing

    for_all pid, fn
      (s, s) -> 1
      ({s, _x2}, {s, _y2}) -> 1
      ({_x1, s}, {_y1, s}) -> 1
      ({x1, x2}, {y1, y2}) when x1+x2 == y1+y2 -> 1
      ({x1, x2}, {y1, y2}) when x1-x2 == y1-y2 -> 1
      (_, _) -> 0
    end

    A.label pid
    state = A.get_state pid

    assert (n * n - n) / 2 == length state.constraints
    assert 0 == state.cost
  end
end
