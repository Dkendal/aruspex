defmodule AruspexTest do
  use ExUnit.Case, async: true
  use Aruspex.Constraint
  doctest Aruspex

  test "compute_cost/1" do
    variables = [:x, :y]

    {:ok, pid} = Aruspex.start_link

    for v <- variables, do: Aruspex.variable(pid, v, [1])

    :ok = Aruspex.post pid, linear(^:x != 1)
    :ok = Aruspex.post pid, linear(^:y != 1)
    :ok = Aruspex.post pid, linear(^:y != ^:x)

    state = :sys.get_state(pid)
    Aruspex.stop pid

    state = put_in state.variables.x.binding, 1
    state = put_in state.variables.y.binding, 1
    state = Aruspex.compute_cost(state)

    assert 1.0e9 * 2 == state.variables.x.cost
    assert 1.0e9 * 3 = state.cost
  end
end
