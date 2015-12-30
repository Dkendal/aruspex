defmodule AruspexTest do
  alias Aruspex.{Evaluation, Strategy.Dfs}
  use Aruspex.Case
  require Logger

  setup do
    import Aruspex.Problem
    import Aruspex.Strategy

    colors = ~w(red green blue)a

    variables = [
      wa  = :western_australia,
      nt  = :nothern_territory,
      q   = :queensland,
      sa  = :south_australia,
      nsw = :new_south_wales,
      v   = :victoria,
            :tasmania
    ]

    problem = new
    for v <- variables, do: add_variable(problem, v, colors)

    problem
    |> post(wa,   nt,   & &1 != &2)
    |> post(wa,   sa,   & &1 != &2)
    |> post(sa,   nt,   & &1 != &2)
    |> post(sa,   q,    & &1 != &2)
    |> post(sa,   nsw,  & &1 != &2)
    |> post(sa,   v,    & &1 != &2)
    |> post(nt,   q,    & &1 != &2)
    |> post(q,    nsw,  & &1 != &2)
    |> post(nsw,  v,    & &1 != &2)

    {:ok, problem: problem}
  end


  test "end to end test", c do
    [result, _] = c.problem
    |> Aruspex.Strategy.SimulatedAnnealing.set_strategy()
    |> Enum.take(2)

    assert result.valid? == true
    Logger.info """
    SimulatedAnnealing completed map colouring in #{result.step} iterations
    """
  end
end
