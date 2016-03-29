defmodule Aruspex.Strategy.Ac3Test do
  use Aruspex.Case

  setup do
    import Aruspex.Problem
    problem = new

    problem
    |> add_variable(:x, 1..10)
    |> add_variable(:y, 1..10)
    |> add_variable(:z, 1..10)
    |> post([:x, :y, :z], fn x, y, z ->
      x + y == z
    end)

    assignment = %Aruspex.Evaluation{problem: problem}

    { :ok, problem: problem, assignment: assignment }
  end

  test "solves basic constraints", %{problem: problem} do
    import Aruspex.Problem
  end

  describe "choose/1" do
    it "returns an unbound variable", %{ assignment: assignment } do
      assert Aruspex.Strategy.Ac3.choose(assignment) in [:x, :y, :z]
    end
  end
end
