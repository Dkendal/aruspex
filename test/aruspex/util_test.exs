defmodule Aruspex.UtilTest do
  use ExUnit.Case
  use Aruspex.Util

  test "z combinator" do
    factorial = z fn
        (1) -> 1
        (n) -> n * this.(n - 1)
    end

    assert factorial.(5) == 120
  end
end
