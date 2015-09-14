defmodule Aruspex.Constraint do
  import Aruspex, only: [get_terms: 1, post: 3]
  require Macro
  require Record
  import Record, only: :macros

  @moddoc """
  Contains helpers and macros for creating constraints.
  """

  defrecord :constraint, variables: [], function: :undefined

  defmacro __using__ _opts do
    quote do
      import unquote(__MODULE__), only: :macros
      require unquote(__MODULE__)

      import unquote(__MODULE__).Common
      require unquote(__MODULE__).Common
    end
  end

  defmacro linear constraint do
    build_linear(constraint)
  end

  def build_linear constraint do
    {expr, substitutions} = Macro.postwalk constraint, %{},
      &replace_bound_terms/2

    terms = Dict.keys(substitutions)
    bound_vars = Dict.values(substitutions)

    quote do
      unquote(__MODULE__).constraint(
        variables: unquote(terms),
        function: unquote(constraint_fun(bound_vars, expr, 1)))
    end
  end

  def test_constraint(c, binding) do
    binding = binding
              |> Dict.take(constraint(c, :variables))
              |> Dict.values
    constraint(c, :function).(binding)
  end

  defp conjunct_clauses [a, b|t] do
    conjunct_clauses [b|t], a
  end

  # define a variable that will appear in the body of a constraint
  # if it's a variable than keep the name, but it should be module scoped
  defp constraint_var({t, _, __CALLER__}), do: {t, [], __MODULE__}
  defp constraint_var(name), do: Macro.var(:"var_#{name}", __MODULE__)

  # replace any ^x variable with a variable and add it to the accumulator
  defp replace_bound_terms {:^, _, [term]}, acc do
    variable = constraint_var(term)
    acc = put_in(acc, [term], variable)
    {variable, acc}
  end
  # no-op
  defp replace_bound_terms(t, dict), do: {t, dict}

  defp constraint_fun bound_vars, expr, cost do
    quote do
      fn
        unquote(bound_vars) when unquote(expr) -> 0
        unquote(bound_vars) -> unquote(cost)
      end
    end
  end
end
