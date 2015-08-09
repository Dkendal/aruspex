defmodule AruspexTest do
  use ExUnit.Case

  @tag timeout: 1000
  test "4 queens" do
    {:ok, pid} = Aruspex.start_link

    variables = [:w, :x, :y, :z]
    pid |> Aruspex.variables(variables)
    pid |> Aruspex.domain(variables, (for i <- 1..4, j <- 1..4, do: {i,j}))

    queen_constraints(pid, variables)

    labels = pid |> Aruspex.label

    assert labels[:w] == {1,2}
    assert labels[:x] == {2,4}
    assert labels[:y] == {3,1}
    assert labels[:z] == {4,3}
  end

  def queen_constraints(_pid, [_x]), do: {:ok}

  def queen_constraints(pid, [x|t]) do
    for y <- t do
      pid |> Aruspex.constraint [x, y], fn
        (s, s) -> false
        ({s, _x2}, {s, _y2}) -> false
        ({_x1, s}, {_y1, s}) -> false
        ({x1, x2}, {y1, y2}) when x1+x2 == y1+y2 -> false
        ({x1, x2}, {y1, y2}) when x1-x2 == y1-y2 -> false
        (_, _) -> true
      end
    end

    queen_constraints(pid, t)
  end
end
