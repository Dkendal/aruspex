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
    :ok = A.set_strategy pid, Aruspex.Strategy.SimulatedAnnealing

    for_all pid, fn
      (s, s) -> 1
      ({s, _x2}, {s, _y2}) -> 1
      ({_x1, s}, {_y1, s}) -> 1
      ({x1, x2}, {y1, y2}) when x1+x2 == y1+y2 -> 1
      ({x1, x2}, {y1, y2}) when x1-x2 == y1-y2 -> 1
      (_, _) -> 0
    end

    solution = A.find_solution pid

    assert [{1,w}, {2,x}, {3,y}, {4,z}] = solution

    variables = [w, x, y, z]
    expected = [{1, 3}, {2, 1}, {3, 4}, {4, 2}]

    assert variables == expected or
           variables == transpose(expected)
  end

  defp transpose a do
    (for {x,y} <- a, do: {y,x})
    |> Enum.sort
  end
end
