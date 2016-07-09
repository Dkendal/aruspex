defmodule Aruspex.Strategy.Ac3 do
  @behaviour Aruspex.Strategy

  import Aruspex.Problem

  defstruct problem: nil, timeout: 5000

  @doc """
  Set the search strategy as AC3 Arc Consistency.
  """
  def set_strategy(problem, opts \\ []) do
    opts = Enum.into opts, %{}
    struct __MODULE__, Map.put(opts, :problem, problem)
  end

  def choose(evaluation) do
    problem = evaluation.problem

    bound_variables = Dict.keys(evaluation.binding)

    variables = variables(problem)
                |> remove_hidden
                |> most_constrained(problem)

    Enum.find variables, fn variable ->
      not variable in bound_variables
    end
  end
end

defimpl Enumerable, for: Aruspex.Strategy.Ac3 do
  use Aruspex.Strategy
  import Aruspex.Strategy.Ac3

  # if complete
  #   return result
  # choose an unbound variable v
  # select a value from the domain
  # collapse domain to v
  # for each edge, collapse domains to values that hold true
  def reduce(s, {:cont, acc}, fun) do
    { :done, acc }
  end
end
