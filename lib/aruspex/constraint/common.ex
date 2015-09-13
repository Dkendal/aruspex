defmodule Aruspex.Constraint.Common do
  @moduledoc """
  Provides common constraints.
  """

  # Because of complexities of attempting to reference a runtime variable during
  # compilation time, this mixes usage of generated quoted expression and
  # runtime evaluation. The alternative is the the input to vars must always be
  # a literal. Going that route would severly impact usablily, and would limit
  # all input to array's known at compilation time.  An alternative
  # implementation would be converting a conjuction of n horn-clauses into n
  # nested functions, where each result is and'd with the current clause. To
  # facilitate that type of behavior though would require modification to how
  # costs are computed: currently erlang:apply is called to apply the binding
  # list to the constraint function. Do to this implementaion the constraint
  # function must be generated with an arity that matches the number of
  # variables. Changing this to support a dict or list could remedy
  # aforementioned issues.
  def all_diff vars do
    require Aruspex.Constraint
    vars = Enum.sort vars
    for x <- vars, y <- vars, y > x do
      quote do: ^unquote(x) != ^unquote(y)
    end
    |> conjunct_clauses
    |> Aruspex.Constraint.build_linear
    |> Code.eval_quoted([], __ENV__) # I hope noone reads what I've done here
    |> case do
      {constraint, []} -> constraint
    end
  end

  defp conjunct_clauses [a, b|t] do
    conjunct_clauses [b|t], a
  end

  defp conjunct_clauses([], acc), do: acc
  defp conjunct_clauses [a|t], acc do
    acc = quote do: unquote(a) and unquote(acc)
    conjunct_clauses(t, acc)
  end
end
