defmodule Examples.MapColouring do
  @shortdoc "Returns a new example problem"

  @doc """
  Returns a constraint problem that formulates the map colouring problem, using
  Australias and its territories as a basis for the problem.

  This specific instance of the problem is restricts the domain of each
  variable to three values (red, green, and blue).
  """

  @spec new() :: Aruspex.Problem
  def new do
    import Aruspex.Problem, except: [new: 0]
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

    problem = Aruspex.Problem.new
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

    problem
  end
end
