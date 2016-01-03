defmodule Aruspex.Constraint do
  def test(false, _binding), do: raise "invalid constraint"

  @doc """
  Apply a binding to a unary constraint. Returns the value of the constraint
  function.
  """
  def test({_e, v, v, c}, binding), do: c.(binding[v])

  @doc """
  Apply a binding to a binary constraint. Returns the value of the constraint.
  """
  def test({_e, v1, v2, c}, binding), do: c.(binding[v1], binding[v2])

  def variables({_e, v1, v2, _c}), do: {v1, v2}
end
