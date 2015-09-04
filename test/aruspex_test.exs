defmodule QueenTest do
  defmacro run strategy, queens do
    quote do
      @tag timeout: 100000
      test "#{unquote queens} queens" do
        variables = :lists.seq(1, unquote queens)

        {:ok, pid} = Aruspex.start_link

        pid |> Aruspex.set_strategy unquote(strategy)
        pid |> Aruspex.variables(variables)

        for v <- variables do
          pid |> Aruspex.domain([v], (for i <- 1..length(variables), do: {v,i}))
        end

        Enum.reduce variables, variables, fn
          (_, [_]) -> :ok
          (_, [x|t]) ->
            for y <- t do
              pid |> Aruspex.constraint [x, y], fn
                (s, s) -> 1
                ({s, _x2}, {s, _y2}) -> 1
                ({_x1, s}, {_y1, s}) -> 1
                ({x1, x2}, {y1, y2}) when x1+x2 == y1+y2 -> 1
                ({x1, x2}, {y1, y2}) when x1-x2 == y1-y2 -> 1
                (_, _) -> 0
              end
            end
            t
        end

        pid |> Aruspex.label
        state = pid |> Aruspex.get_state
        assert 0 == state.cost
      end
    end
  end
end

defmodule AruspexTest do
  use ExUnit.Case, async: true

  test "compute_cost/1" do
    {:ok, pid} = Aruspex.start_link
    pid |> Aruspex.variables([:x, :y])
    pid |> Aruspex.domain([:x, :y], [1])
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
