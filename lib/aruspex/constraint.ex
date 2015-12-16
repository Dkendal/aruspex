defmodule Aruspex.Constraint do
  alias Aruspex.Var
  import Record, only: :macros
  require Macro
  require Record

  @moddoc """
  Contains helpers and macros for creating constraints.
  """

  defrecord :constraint, variables: [], function: :undefined
  @type t :: record(
    :constraint,
    variables: [Var.name],
    function: ([Var.name] -> Var.cost)
  )

  defmacro __using__ _opts do
    quote do
      import unquote(__MODULE__), only: :macros
      require unquote(__MODULE__)

      import unquote(__MODULE__).Common
      require unquote(__MODULE__).Common
    end
  end

  @doc """
  The linear macro provides a succinct method of defining simple constraints.

  Both forms of `linear/{1,2}` only supports clauses that are capable of being
  inlined (i.e expressions that can appear in guard clauses).

  ```
  pid
  |> post(linear ^:x == ^:y)
  ```

  Pinned literals inside the arguments of `linear/1` indicate that the value
  refers to a named variable which will be substituted in during compilation.
  Pinned variables may also be used to the same effect.  Unpinned values will
  be used by value.

  ```
  some_var = :x
  z = 1
  pid
  |> post(linear ^some_var == ^:y + z)
  ```

  is equivalent to:

  ```elixir
  pid
  |> post(linear ^:x == ^:y + 1)
  ```
  """
  defmacro linear constraint do
    build_linear(constraint)
  end


  @doc """
  In its second form, the named variables may be defined explicitly as the
  first argument, and matched on.

  ```elixir
  pid
  |> post(linear [:x, :y],
                 [{x1, _}, {_, y2}] when x1 == y2)
  ```
  """
  defmacro linear v, clause do
    quote do
      unquote(__MODULE__).constraint(
      variables: unquote(v),
      function: fn
        unquote(clause) -> 0
        _ -> 1
      end)
    end
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
  defp constraint_var({t, _, __CALLER__}), do: {:"v__#{t}", [], __MODULE__}
  defp constraint_var(name), do: Macro.var(:"d__#{name}", __MODULE__)

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
