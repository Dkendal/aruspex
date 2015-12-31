defmodule Aruspex.Strategy.DfsTest do
  use Aruspex.Case

  it "solves the map colouring problem" do
    [result] = Examples.MapColouring.new
    |> Aruspex.Strategy.Dfs.set_strategy()
    |> Enum.take(1)

    assert result.valid? == true
  end
end
