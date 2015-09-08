defmodule Aruspex.Constraint do
  import Aruspex, only: [get_terms: 1, post: 3]
  require Macro

  @moddoc """
  Contains helpers and macros for creating constraints.
  """

  defmacro __using__ _opts do
    quote do
      import unquote(__MODULE__)
      require unquote(__MODULE__)
    end
  end

  defmacro linear v, f do
    var_dict = for x <- v do
      {x, Macro.var(:"var_#{x}", __MODULE__)}
    end
    variables = Keyword.values var_dict

    # replace matched variables in function body with bound variables
    {body, _var_dict} = Macro.postwalk f, var_dict, fn
      {:^, _, [sym]}, v -> {Dict.fetch!(v, sym), v}
      t, v -> {t, v}
    end

    constraint = quote do
      fn
        unquote_splicing(variables) when unquote(body) -> 0
        unquote_splicing(variables) -> 1
      end
    end

    result = quote do
      {:constraint, (unquote v), (unquote constraint)}
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
