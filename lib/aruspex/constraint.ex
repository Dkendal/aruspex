defmodule Aruspex.Constraint do
  import Aruspex, only: [get_terms: 1, post: 3]

  @moddoc """
  Contains helpers and macros for creating constraints.
  """

  defmacro __using__ _opts do
    quote do
      import unquote(__MODULE__)
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
