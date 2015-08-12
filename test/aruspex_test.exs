defmodule AruspexTest do
  use ExUnit.Case

  @tag timeout: 100
  test "4 queens" do
    queens = 4
    variables = :lists.seq(1,queens)

    {:ok, pid} = Aruspex.start_link

    pid |> Aruspex.variables(variables)

    for v <- variables do
      pid |> Aruspex.domain([v], (for i <- 1..length(variables), do: {v,i}))
    end

    queen_constraints(pid, variables)

    iterations = 10
    results = for _ <- 1..iterations do
      {labels, cost} = pid |> Aruspex.label
      actual = labels
      |> Dict.values

      solutions = [
        [{1,2}, {2,4}, {3,1}, {4,3}],
        [{1,3}, {2,1}, {3,4}, {4,2}]]

      assert 0 = cost
      assert actual in solutions
    end
  end

  def queen_constraints(_pid, [_x]), do: :ok

  def queen_constraints(pid, [x|t]) do
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

    queen_constraints(pid, t)
  end
end
