defmodule Aruspex.Evaluation do
  alias Aruspex.Constraint
  import Aruspex.Problem

  defstruct valid?: false,
            complete?: false,
            binding: %{},
            total_cost: 0,
            total_violations: 0,
            step: 0,
            cost: %{},
            violations: %{},
            problem: nil,
            __previous__: nil

  defdelegate get_and_update(e, a, f), to: Map

  def new(problem, binding),
    do: struct(__MODULE__, binding: binding, problem: problem)

  def complete(evaluation),
    do: put_in evaluation.complete?, true

  def incomplete(evaluation),
    do: put_in evaluation.complete?, false

  def valid(evaluation),
    do: put_in evaluation.valid?, true

  def invalid(evaluation),
    do: put_in evaluation.valid?, false

  def step(evaluation),
    do: update_in(evaluation.step, & &1 + 1)

  def bind(evaluation, binding),
    do: put_in evaluation.binding, binding

  def completeness(evaluation) do
    s1 = evaluation.problem |> variables |> MapSet.new
    s2 = evaluation.binding |> Dict.keys |> MapSet.new

    if MapSet.equal?(s1, s2) do
      complete evaluation
    else
      incomplete evaluation
    end
  end

  @default_evaluation_options %{
    fail_fast: false
  }

  def evaluation(evaluation, opts \\ @default_evaluation_options)
  def evaluation(evaluation, opts) do

    evaluation =
      evaluation
      |> reset
      |> step

    do_evaluation = &do_evaluation &1, &2, opts

    g =
      evaluation.problem
      |> subproblem(evaluation.binding)

    g
    |> labeled_constraints
    |> Enum.flat_map_reduce(evaluation, do_evaluation)
    |> elem(1)
    |> case do
      x ->
        # release ets tables
        delete(g)
        x
    end
  end

  def do_evaluation(c, acc, opts) when is_tuple(c),
    do: do_evaluation c, Constraint.test(c, acc.binding), acc, opts

  defp do_evaluation(_c, true, acc, _opts),
    do: {[], acc}

  defp do_evaluation(_c, false, acc, %{fail_fast: true}),
    do: {:halt, invalid(acc)}

  defp do_evaluation(c, false, acc, %{fail_fast: false}) do
    {v1, v2} = Constraint.variables(c)
    acc =
      acc
      |> invalid
      |> inc_violation(v1)
      |> inc_violation(v2)
      |> inc_total_violations

    {[], acc}
  end

  defp do_evaluation(c, x, acc, _opts) when is_number(x) do
    {v1, v2} = Constraint.variables(c)
    acc =
      acc
      |> add_cost(v1, x)
      |> add_cost(v2, x)
      |> add_total_cost(x)

    {[], acc}
  end

  def reset(evaluation) do
    prev = Map.delete evaluation, :__previous__

    evaluation
    |> put_in([:__previous__], prev)
    |> put_in([:total_cost], 0)
    |> put_in([:total_violations], 0)
    |> put_in([:cost], %{})
    |> put_in([:violations], %{})
    |> valid
    |> completeness
  end

  defp add_total_cost(acc, cost),
    do: update_in(acc.total_cost, & &1 + cost)

  defp add_cost(acc, v, cost),
    do: update_in(acc, [:cost, v], & (&1 || 0) + cost)

  defp inc_total_violations(acc),
    do: update_in(acc, [:total_violations], & &1 + 1)

  defp inc_violation(acc, v),
    do: update_in(acc, [:violations, v], & (&1 || 0) + 1)
end
