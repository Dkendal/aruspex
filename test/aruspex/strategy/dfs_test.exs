defmodule Aruspex.Strategy.DfsTest do
  use Aruspex.Case

  test "solves the map colouring problem" do
    results = Examples.MapColouring.new
    |> Aruspex.Strategy.Dfs.set_strategy()
    |> Enum.take(2)

    Aruspex.Logger.log_stats results

    assert (hd results).valid? == true
  end
end
