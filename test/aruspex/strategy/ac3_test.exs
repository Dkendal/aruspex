defmodule Aruspex.Strategy.Ac3Test do
  use Aruspex.Case
  import Aruspex.Strategy.Ac3

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
    |> post(:y, & rem(&1, 2) == 0)

    assignment = %Aruspex.Evaluation{problem: problem}

    { :ok, problem: problem, assignment: assignment }
  end

  test "solves basic constraints", %{problem: problem} do
    import Aruspex.Problem
  end

  describe "choose/1" do
    it "returns the most constraint unbound variable",
    %{ assignment: assignment } do
      import Aruspex.Evaluation

      assert choose(assignment) == :y

      assert choose(bind(assignment, y: 1)) in [:x, :z]
    end
  end
end
