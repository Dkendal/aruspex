defmodule Aruspex.ProblemTest do
  alias Aruspex.{Evaluation, Problem}
  use Aruspex.Case

  describe "post/2" do
    context "with a nonbinary constraint" do
      it "converts it into many binary constraints" do
        p = Problem.new

        p |> Problem.add_variable(:x, 1..9)
          |> Problem.add_variable(:y, 1..9)
          |> Problem.add_variable(:z, 1..9)
          |> Problem.post([:x, :y, :z], & &1 + &2 == &3)

        assert Problem.no_variables(p) == 4
        assert Problem.no_constraints(p) == 1

        result = %Evaluation{problem: p, binding: %{x: 1, y: 2, z: 4}}
                  |> Evaluation.evaluation
      end
    end
  end
end
