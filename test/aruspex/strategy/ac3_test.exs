defmodule Aruspex.Strategy.Ac3Test do
  use Aruspex.Case

  test "solves basic constraints" do
    import Aruspex.Problem
    problem = new

    assignments =
    problem
    |> add_variable(:x, 1..10)
    |> add_variable(:y, 1..10)
    |> add_variable(:z, 1..10)
    |> post([:x, :y, :z], fn x, y, z ->
      x + y == z
    end)
    |> Aruspex.Strategy.Ac3.set_strategy([])
    |> Enum.take(2)

    IO.inspect assignments
  end
end
