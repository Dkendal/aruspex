defmodule Aruspex.ProblemTest do
  alias Aruspex.{Evaluation, Problem}
  use Aruspex.Case

  describe "post/3" do
    test "adds a binary constraints" do
      p = Problem.new
      p |> Problem.add_variable(:x, 1..9)
        |> Problem.add_variable(:y, 1..9)
        |> Problem.post(:x, :y, &!=/2)

        assert Problem.no_constraints(p) == 1
    end
  end

  describe "post/2" do
    #TODO this could proably, under some circumstances, be implimented as a
    # domain reduction. It could be difficult to determine if the statement
    # can be used as a reduction. Perhaps if it's a valid guard statement
    # than it is non deterministic and can be used to reduce the domain.
    test "with a unary constaint adds a unary constraint" do
      p = Problem.new
      p |> Problem.add_variable(:x, 1..9)
        |> Problem.post(:x, & &1 > 2)

        assert Problem.no_constraints(p) == 1
    end

    test "with a nonbinary constraint converts it into many binary constraints" do
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

  describe "labeled_variables/2" do
    test "returns the variables along with their domain" do
      assert [ x: 1..9 ] == Problem.new
                          |> Problem.add_variable(:x, 1..9)
                          |> Problem.labeled_variables()
    end

    test "does not return hidden variables" do
      actual = Problem.new
                |> Problem.add_variable(:x, 1..9)
                |> Problem.add_variable(:y, 1..9)
                |> Problem.add_variable(:z, 1..9)
                |> Problem.post([:x, :y, :z], & &1 + &2 == &3)
                |> Problem.labeled_variables()

        assert [ z: 1..9, y: 1..9, x: 1..9 ] == actual
    end
  end
end
