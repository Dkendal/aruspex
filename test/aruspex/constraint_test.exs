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

    it "preserves external variables" do
      x = 10
      f = constraint linear(x - 2 * ^x == 0), :function
      assert f.([5]) == 0
      assert f.([1]) == 1
    end

    describe "generated constraint function" do
      it "returns 0 when satisfied", c do
        assert c.function.([1]) == 0
      end

      it "returns 1 when violated", c do
        assert c.function.([0]) == 1
      end
    end

    context "with variables specified" do
      it "behaves the same" do
        c = linear([:x, :y], [x, y] when x == y)
        f = constraint(c, :function)

        assert constraint(c, :variables) == [:x, :y]
        assert f.([1,1]) == 0
        assert f.([1,2]) == 1
      end
    end
  end

  describe "test_constraint/2" do
    setup do
      c = constraint(variables: [:x, :y], function: fn
        [x, x] -> 1
        [x, y] -> flunk """
        should be unreachable, called with #{inspect x}, #{inspect y}"
        """
      end)

      {:ok, constraint: c}
    end

    it "evaluates a constraint with a specified binding", config do
      assert(
        Aruspex.Constraint.test_constraint(
          config.constraint,
          [x: 1, y: 1, z: 2]
        ) == 1
      )
    end

    context "when the constraint has a variable that is unbound"do
      it 'raises an error' do
        assert_raise Aruspex.ConstraintArgumentError, ~r/Missing:\n.*[:y]/, fn
          ->
            linear(^:y == 1)
            |> Aruspex.Constraint.test_constraint([x: 1])
        end
      end
    end
  end
end
