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

    {:ok, problem: problem}
  end

  test "get_and_update_in/3" do
    e = update_in(%Aruspex.Evaluation{}, [:cost, :x], fn _ -> 1 end)
    assert e.cost.x == 1
  end

  test "evaluation/1", c do
    e =
      %Evaluation{problem: c.problem, binding: %{x: 1, y: 2, z: 3}}
      |> evaluation
      |> evaluation
      |> evaluation

    assert e.valid? == true
    assert e.total_cost == 3
    assert e.cost.x == 3
    assert e.cost.y == 3
    assert e.step == 3

    e =
      %Evaluation{problem: c.problem, binding: %{x: 2, y: 2, z: 3}}
      |> evaluation

    assert e.valid? == false
    assert e.step == 1
    assert e.total_violations == 1
    assert e.violations == %{x: 1, y: 1}

    e =
      e
      |> bind(%{x: 1, y: 2, z: 3})
      |> evaluation

    assert e.valid? == true
    assert e.step == 2
    assert e.total_violations == 0
    assert e.violations == %{}
  end
end
