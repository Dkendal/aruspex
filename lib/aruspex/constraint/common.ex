defmodule Aruspex.Constraint.Common do
  require Aruspex.Constraint

  @moduledoc """
  Provides common constraints.
  """

  @doc """
  All different constraint. All variables specified in vars will be tested for
  uniqueness. Implemented with Hash table lookup, O(n log(n)).

  ## e.g.
  iex> Aruspex.post pid, all_diff([:x, :y, :z])
  """
  def all_diff vars do
    Aruspex.Constraint.constraint(
      variables: vars,
      function: &all_diff_constraint/1
    )
  end

  def all_diff_constraint([], _), do: 0
  def all_diff_constraint([h|t], s \\ HashSet.new) do
    case Set.member?(s, h) do
      true -> 1
      false -> all_diff_constraint t, Set.put(s, h)
    end
  end
end
