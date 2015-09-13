defmodule Aruspex.ConstraintTest do
  use ExSpec, async: true
  use Aruspex.Constraint

  describe "linear/2" do
    setup do
      subject = linear(^:x == 1)
      function = constraint(subject, :function)
      variables = constraint(subject, :variables)
      {:ok,
        subject: subject,
        function: function,
        variables: variables}
    end

    it "extracts the pariticipating variables", c do
      assert c.variables == [:x]
    end

    describe "generated constraint function" do
      it "has a constraint function with arity matching number of vars", c do
        c.function
        |> is_function(1)
        |> assert
      end

      it "returns 0 when satisfied", c do
        assert c.function.(1) == 0
      end

      it "returns 1 when violated", c do
        assert c.function.(0) == 1
      end
    end
  end
end
