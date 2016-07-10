defmodule Examples.FourQueens do

  def new() do
    import Aruspex.Problem, except: [new: 0]
    import Aruspex.Strategy

    domain = 1..4
    vars = for x <- domain, do: :"var-#{x}"

    problem = Aruspex.Problem.new

    Enum.map vars, &add_variable(problem, &1, domain)

    for x <- domain, y <- domain, y > x do
      a = Enum.at(vars, x - 1)
      b = Enum.at(vars, y - 1)

      problem
      |> post(a, b, & &1 != &2)
      |> post(a, b, fn a, b -> a + x != b + y end)
      |> post(a, b, fn a, b -> a - x != b - y end)
    end

    problem
  end
end
