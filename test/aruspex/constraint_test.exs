defmodule Aruspex.ConstraintTest do
  use Aruspex.Case

  describe "linear/2" do
    let :macro do
      use Aruspex.Constraint
      quote do: linear(^:x == 1)
    end

    let :code do
      quote do
        {:constraint, [:x], fn
          var_x when var_x == 1 ->
            0
          var_x ->
            1.0e9
        end}
      end
    end

    it "generates the expected output" do
      expect(macro) |> to_generate code
    end
  end
end
