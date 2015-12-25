defmodule Aruspex.StateTest do
  alias Aruspex.State
  alias Aruspex.Var
  use Aruspex.Case
  use Aruspex.Constraint

  describe "compute_cost/1" do
    setup do
      variables = 1..10

      state = struct Aruspex.State

      state = Enum.reduce(variables, state, fn v, state ->
        state = State.set_var(state, v, [1] |> Var.new |> Var.bind(1))

        Enum.reduce(variables, state, fn w, state ->
          if v > w do
            State.add_constraint(state, linear ^v != ^w)
          else
            state
          end
        end)
      end)

      state = State.compute_cost(state)

      {:ok, %{state: state}}
    end

    it "returns the cost, and an updated state", c do
    end
  end
end
