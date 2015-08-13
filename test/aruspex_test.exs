defmodule AruspexTest do
  use ExUnit.Case

  @tag timeout: 10000
  test "Queens" do
    iterations = 10
    run = fn (queens) ->
      variables = :lists.seq(1,queens)

      {:ok, pid} = Aruspex.start_link

      pid |> Aruspex.variables(variables)

      for v <- variables do
        pid |> Aruspex.domain([v], (for i <- 1..length(variables), do: {v,i}))
      end

      queen_constraints(pid, variables)

      for _ <- 1..iterations do
        {_labels, steps, cost} = pid |> Aruspex.label
        {steps, cost}
      end
      |> Enum.reduce({0,0,0}, fn({steps, cost}, {s, c, a}) ->
      solved = if cost == 0 do 1 else 0 end

      {steps + s, cost + c, a + solved}
      end)
      |> case do
        {s, c, solved} ->
          IO.puts """
          #{queens} Queens:
          Iterations: #{iterations}
          Average steps: #{s/iterations}
          Average energry: #{c/iterations}
          Solutions found: #{solved}
          """
      end
    end

    for queens <- 4..8 do
      run.(queens)
    end
  end

  def queen_constraints(_pid, [_x]), do: :ok

  def queen_constraints(pid, [x|t]) do
    for y <- t do
      pid |> Aruspex.constraint [x, y], fn
        (s, s) -> 1
        ({s, _x2}, {s, _y2}) -> 1
        ({_x1, s}, {_y1, s}) -> 1
        ({x1, x2}, {y1, y2}) when x1+x2 == y1+y2 -> 1
        ({x1, x2}, {y1, y2}) when x1-x2 == y1-y2 -> 1
        (_, _) -> 0
      end
    end

    queen_constraints(pid, t)
  end
end
