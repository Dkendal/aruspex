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
    e = update_in(%Evaluation{}, [:cost, :x], fn _ -> 1 end)
    assert e.cost.x == 1
  end

  describe "evaluation/1" do
    it "increments the step counter", config do
      result = config.valid_assignment
                |> evaluation
                |> evaluation
                |> evaluation

      assert result.step == 3
    end

    context "with soft constraints/preferences" do
      it "sets the cost of assignments" do
        p = new
        p |> add_variable(:x, 1..10)
          |> add_variable(:y, 1..10)
          |> post(:x, :y, fn x, y -> x + y end)
          |> post(:x, & &1 >= 2)
          |> post(:x, & &1)

        result = evaluation %Evaluation{problem: p, binding: %{x: 2, y: 2}}
        assert result.valid? == true
        assert result.total_cost == 6
        assert result.cost.x == 6
        assert result.cost.y == 4
      end
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

  describe "hidden_assigment/1" do
    it "assigns the substituted variables to the hidden variable" do
      p = Problem.new

      p |> Problem.add_variable(:x, 1..9)
        |> Problem.add_variable(:y, 1..9)
        |> Problem.add_variable(:z, 1..9)
        |> Problem.post([:x, :y, :z], & &1 + &2 == &3)

      result = %Evaluation{problem: p, binding: %{x: 1, y: 2, z: 4}}
                |> Evaluation.hidden_assigment

      assert Enum.any? result.binding, fn
        {{:hidden, _, _}, %{x: 1, y: 2, z: 4}} ->
          true

        {_, _} ->
          false
      end
    end
  end
end
