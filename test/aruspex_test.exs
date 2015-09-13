defmodule AruspexTest do
  use Aruspex.Case
  use Aruspex.Constraint

  describe "compute_cost/1" do
    subject do
      Aruspex.compute_cost(state)
    end

    let :variables, do: [:x, :y]

    let :state do
      use Aruspex.Constraint

      {:ok, pid} = Aruspex.start_link

      for v <- variables, do: Aruspex.variable(pid, v, [1])

      :ok = Aruspex.post pid, linear(^:x != 1)
      :ok = Aruspex.post pid, linear(^:y != 1)
      :ok = Aruspex.post pid, linear(^:y != ^:x)

      state = :sys.get_state(pid)
      Aruspex.stop pid

      state = put_in state.variables.x.binding, 1
      state = put_in state.variables.y.binding, 1
    end

    it "returns the cost, and an updated state" do
      expect(subject.cost) |> to_eq 3
    end
  end
end
