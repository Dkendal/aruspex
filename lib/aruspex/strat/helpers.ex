defmodule Aruspex.Strat.Helpers do
  def found_solution(solution, caller) do
    send caller, {:solution, self, solution}
  end
end
