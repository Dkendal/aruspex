defmodule Aruspex.EvaluationTest do
  alias Aruspex.{Evaluation, Problem}
  import Aruspex.Evaluation
  import Aruspex.Problem
  use Aruspex.Case

  setup do
    problem = Problem.new
    problem |> add_variable(:x, 1..3)
    problem |> add_variable(:y, 1..3)
    problem |> add_variable(:z, 1..3)
    problem |> post(:x, :y, &!=/2)
    problem |> post(:x, :z, &!=/2)
    problem |> post(:y, :z, &!=/2)
    problem |> post(:x, :y, &+/2)

    valid_assignment = %Evaluation{
      problem: problem,
      binding: %{x: 1, y: 2, z: 3}}

    invalid_assignment = %Evaluation{
      problem: problem,
      binding: %{x: 2, y: 2, z: 3}}

    { :ok,
      problem: problem,
      invalid_assignment: invalid_assignment,
      valid_assignment: valid_assignment}
  end

  test "get_and_update_in/3" do
    e = update_in(%Aruspex.Evaluation{}, [:cost, :x], fn _ -> 1 end)
    assert e.cost.x == 1
  end

  describe "evaluation/1" do
    it "sets computed values for the assignment", config do
      result = config.valid_assignment
                |> evaluation
                |> evaluation
                |> evaluation

      assert result.valid? == true
      assert result.total_cost == 3
      assert result.cost.x == 3
      assert result.cost.y == 3
      assert result.step == 3
      assert result.total_violations == 0
      assert result.violations == %{}
    end

    context "with a invalid assignment" do
      it "marks the evaluation as invalid", config do
        result = evaluation config.invalid_assignment
        assert result.valid? == false
        assert result.step == 1
        assert result.total_violations == 1
        assert result.violations == %{x: 1, y: 1}
      end
    end
  end
end
