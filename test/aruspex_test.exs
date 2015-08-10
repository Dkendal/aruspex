defmodule AruspexTest do
  use ExUnit.Case

  @tag timeout: :infinity
  test "4 queens" do
    {:ok, pid} = Aruspex.start_link

    variables = [:w, :x, :y, :z]
    pid |> Aruspex.variables(variables)
    pid |> Aruspex.domain(variables, (for i <- 1..4, j <- 1..4, do: {i,j}))

    queen_constraints(pid, variables)

    labels = pid |> Aruspex.label

    actual = labels
    |> Dict.values
    |> Enum.sort

    solution_1 = [{1,2}, {2,4}, {3,1}, {4,3}] |> Enum.sort

    solution_2 = [{2,1}, {4,2}, {1,3}, {3,4}] |> Enum.sort

    assert actual == solution_1 || actual == solution_2
  end

  def queen_constraints(_pid, [_x]), do: {:ok}

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
