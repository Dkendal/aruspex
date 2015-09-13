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
      import unquote(__MODULE__)
      require unquote(__MODULE__)
    end
  end

  defmacro linear constraint do
    cost = 1

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

  def for_all pid, f do
    for_all pid, get_terms(pid), f
  end

  def for_all pid, domain, f do
    domain = domain |> Enum.sort

    for x <- domain, y <- domain, y < x do
      post pid, [x, y], f
    end
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
        unquote_splicing(bound_vars) when unquote(expr) -> 0
        unquote_splicing(bound_vars) -> unquote(cost)
      end
    end
  end
end
