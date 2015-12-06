defmodule Aruspex do
  import Enum, only: [reduce: 3]
  import Aruspex.State

  @moduledoc """
  Aruspex Solver

  Aruspex is a generic, mostly JSR-331 compliant cp solver which can solve
  typical linear constraint problems.
  """

  defdelegate [
    start_link(),
    start_link(options),
    stop(pid),
    variable(pid, v, d),
    post(pid, c),
    find_solution(pid),
    set_search_strategy(pid, strategy),
    get_terms(pid)
  ], to: __MODULE__.Server
end
