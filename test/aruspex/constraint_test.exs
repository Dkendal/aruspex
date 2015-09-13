defmodule Aruspex.ConstraintTest do
  use Aruspex.Case

  describe "linear/2" do
    let :subject do
      use Aruspex.Constraint
      linear(^:x == 1)
    end

    it "extracts the pariticipating variables" do
      use Aruspex.Constraint
      expect(constraint subject, :variables) |> to_eq [:x]
    end

    it "has a constraint function with arity matching number of vars" do
      use Aruspex.Constraint
      expect(constraint(subject, :function))
      |> is_function(1)
      |> to_be_true
    end
  end
end
