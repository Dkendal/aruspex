defmodule Aruspex.Constraint.CommonTest do
  use ExSpec, async: true
  use Aruspex.Constraint

  setup do
    c = all_diff([:x, :y, :z])
    { :ok,
      constraint: c,
      function: constraint(c, :function) }
  end

  describe "all_diff/1" do
    describe "constraint function" do
      it "has a function with arity matching number of args", c do
        constraint(c.constraint, :function)
        |> is_function(3)
        |> assert
      end

      it "returns 0 when all variables are different", %{function: function} do
        assert function.(1,2,3) == 0
      end

      it "returns 1 when any variables are the same", %{function: function} do
        assert function.(1,1,1) == 1
        assert function.(1,1,2) == 1
        assert function.(1,2,2) == 1
        assert function.(2,1,2) == 1
      end
    end
  end
end
