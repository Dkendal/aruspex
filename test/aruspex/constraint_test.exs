defmodule Aruspex.ConstraintTest do
  use Aruspex.Case

  describe "linear/2" do
    subject do
      use Aruspex.Constraint
      linear(^:x == 1)
    end

    let :function do
      use Aruspex.Constraint
      constraint(subject, :function)
    end

    let :variables do
      use Aruspex.Constraint
      constraint(subject, :variables)
    end

    it "extracts the pariticipating variables" do
      use Aruspex.Constraint
      assert variables == [:x]
    end

    describe "generated constraint function" do
      it "has a constraint function with arity matching number of vars" do
        function
        |> is_function(1)
        |> assert
      end

      it "returns 0 when satisfied" do
        assert function.(1) == 0
      end

      it "returns 1 when violated" do
        assert function.(0) == 1
      end
    end
  end
end
