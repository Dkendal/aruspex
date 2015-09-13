defmodule Aruspex.ConstraintTest do
  use Aruspex.Case

  describe "linear/2" do
    subject do
      use Aruspex.Constraint
      linear(^:x == 1)
    end

    it "extracts the pariticipating variables" do
      use Aruspex.Constraint
      expect(constraint subject, :variables) |> to_eq [:x]
    end

    describe "generated constraint function" do
      let :function do
        use Aruspex.Constraint
        constraint(subject, :function)
      end

      it "has a constraint function with arity matching number of vars" do
        use Aruspex.Constraint
        expect(function)
        |> is_function(1)
        |> to_be_true
      end

      it "returns 0 when satisfied" do
        expect(function.(1)) |> to_eq 0
      end

      it "returns 1 when violated" do
        expect(function.(0)) |> to_eq 1
      end
    end
  end
end
