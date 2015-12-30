defmodule Aruspex.Constraint do
  def test(false, _binding), do: raise "invalid constraint"

  def test({_e, v1, v2, c}, binding), do: test(c, binding[v1], binding[v2])

  def test(_c, x, y) when x == nil or y == nil, do: true

  def test(c, x, y), do: c.(x, y)

  def variables({_e, v1, v2, _c}), do: {v1, v2}
end
