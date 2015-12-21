defmodule Aruspex.Strategy.DfsTest do
  use Aruspex.StrategyCase,
    strategy: Aruspex.Strategy.Dfs

  test "" do
    import Aruspex.Server
    use Aruspex.Constraint

    {:ok, pid} = start_link
    pid
    |> set_search_strategy(Aruspex.Strategy.Dfs)
    |> variable(:x, 1..10)
    |> variable(:y, 1..10)
    |> post(linear ^:x + ^:y == 10)
    |> find_solution
  end
end
