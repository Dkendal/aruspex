defmodule Aruspex.StateTest do
  use ExSpec, async: true
  use Aruspex.Constraint

  describe "compute_cost/1" do
    setup do
      variables = [:x, :y]

      {:ok, pid} = Aruspex.Server.start_link

      for v <- variables, do: Aruspex.Server.variable(pid, v, [1])

      pid
      |> Aruspex.Server.post(linear ^:y != ^:x)
      |> Aruspex.Server.post(linear ^:x != 1)
      |> Aruspex.Server.post(linear ^:y != 1)

      state = :sys.get_state(pid)
      Aruspex.Server.stop pid

      state = put_in state.variables.x.binding, 1
      state = put_in state.variables.y.binding, 1

      {:ok,
        subject: Aruspex.State.compute_cost(state)}
    end

    it "returns the cost, and an updated state", c do
      assert c.subject.cost == 3
    end
  end
end


