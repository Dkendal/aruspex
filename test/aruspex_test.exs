defmodule QueenTest do
  use Aruspex.Constraint

  alias Aruspex, as: A

  defmacro run strategy, queens do
    quote do
      @tag timeout: 100000
      test "#{unquote queens} queens" do
        n = unquote queens
        strategy = unquote strategy

        {:ok, pid} = A.start_link

        for x <- 1..n, do:
          A.variable(pid, x, (for y <- 1..n, do: {x, y}))

        A.set_strategy pid, strategy

        for_all pid, fn
          (s, s) -> 1
          ({s, _x2}, {s, _y2}) -> 1
          ({_x1, s}, {_y1, s}) -> 1
          ({x1, x2}, {y1, y2}) when x1+x2 == y1+y2 -> 1
          ({x1, x2}, {y1, y2}) when x1-x2 == y1-y2 -> 1
          (_, _) -> 0
        end

        pid |> A.label
        state = pid |> A.get_state

        assert unquote((queens * queens - queens) / 2) ==
          length state.constraints

        assert 0 == state.cost
      end
    end
  end
end

defmodule AruspexTest do
  use ExUnit.Case, async: true
  doctest Aruspex

  test "compute_cost/1" do
    variables = [:x, :y]

    {:ok, pid} = Aruspex.start_link

    for v <- variables, do: Aruspex.variable(pid, v, [1])

    pid |> Aruspex.constraint([:x], fn
      1 -> 100
      _ -> flunk "unreachable"
    end)
    pid |> Aruspex.constraint([:y], fn
      1 -> 100
      _ -> flunk "unreachable"
    end)
    pid |> Aruspex.constraint([:y, :x], fn
      s, s -> 100
      _, _ -> flunk "unreachable"
    end)

    state = :sys.get_state(pid)
    state = put_in state.variables.x.binding, 1
    state = put_in state.variables.y.binding, 1

    Aruspex.stop pid

    state = Aruspex.compute_cost(state)

    assert 200 = state.variables.x.cost
    assert 300 = state.cost
  end
end

defmodule Aruspex.Strategy.SimulatedAnnealingTest do
  use ExUnit.Case, async: true
  require QueenTest

  QueenTest.run Aruspex.Strategy.SimulatedAnnealing, 20
end
