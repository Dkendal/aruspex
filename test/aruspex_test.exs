defmodule AruspexTest do
  use ExUnit.Case, async: true
  doctest Aruspex

  test "compute_cost/1" do
    variables = [:x, :y]

    {:ok, pid} = Aruspex.start_link

    for v <- variables, do: Aruspex.variable(pid, v, [1])

    :ok = pid |> Aruspex.post([:x], fn
      1 -> 100
      _ -> flunk "unreachable"
    end)

    :ok = pid |> Aruspex.post([:y], fn
      1 -> 100
      _ -> flunk "unreachable"
    end)

    :ok = pid |> Aruspex.post([:y, :x], fn
      s, s -> 100
      _, _ -> flunk "unreachable"
    end)

    state = :sys.get_state(pid)
    Aruspex.stop pid

    state = put_in state.variables.x.binding, 1
    state = put_in state.variables.y.binding, 1
    state = Aruspex.compute_cost(state)

    assert 200 = state.variables.x.cost
    assert 300 = state.cost
  end
end
