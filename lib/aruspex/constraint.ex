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
    # define a variable that will appear in the body of a constraint
    # all generated variables should be hygenic
    v = fn
      # bound variable
      {t, _, __CALLER__} ->
        {t, [], __MODULE__}
      # interpolated variable
      name ->
        Macro.var(:"var_#{name}", __MODULE__)
    end

    # replace matched bound_vars in function body with bound bound_vars
    {expr, dictionary} = Macro.postwalk constraint, %{}, fn
      {:^, _, [term]}, dict ->
        {v.(term), put_in(dict, [term], v.(term))}

      t, dict ->
        {t, dict}
    end

    terms = Dict.keys dictionary
    bound_vars = Dict.values(dictionary)

    constraint = quote do
      fn
        unquote_splicing(bound_vars) when unquote(expr) -> 0
        unquote_splicing(bound_vars) -> 1
      end
    end

    result = quote do
      unquote(__MODULE__).constraint variables: unquote(terms), function: unquote(constraint)
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
end
