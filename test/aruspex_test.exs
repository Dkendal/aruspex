defmodule QueenTest do
  defmacro run queens do
    quote do
      @tag timeout: 10000
      test "#{unquote queens} queens" do
        iterations = 100
        variables = :lists.seq(1, unquote queens)

        {:ok, pid} = Aruspex.start_link

        pid |> Aruspex.variables(variables)

        for v <- variables do
          pid |> Aruspex.domain([v], (for i <- 1..length(variables), do: {v,i}))
        end

        queen_constraints = fn
          (_pid, [_x], _fun) -> :ok
          (pid, [x|t], queen_constraints) ->
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
            queen_constraints.(pid, t, queen_constraints)
        end

        queen_constraints.(pid, variables, queen_constraints)

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

            #{unquote queens} Queens:
            Iterations: #{iterations}
            Average steps: #{s/iterations}
            Average energry: #{c/iterations}
            Solutions found: #{solved}
            """
            assert ^iterations = solved
        end
      end
    end
  end
end

defmodule AruspexTest do
  use ExUnit.Case
  require QueenTest

  #QueenTest.run 8
  #QueenTest.run 7
  #QueenTest.run 6
  #QueenTest.run 5
  QueenTest.run 4

  test "compute_cost/1" do
    {:ok, pid} = Aruspex.start_link
    pid |> Aruspex.variables([:x])
    pid |> Aruspex.domain([:x], [1])
    pid |> Aruspex.constraint([:x], fn
      1 -> 100
      _ -> raise "unreachable"
    end)
    pid |> Aruspex.constraint([:x], fn
      1 -> 100
      _ -> raise "unreachable"
    end)

    result = :sys.get_state(pid).variables.x.binding
    |> put_in(1)
    |> Aruspex.compute_cost()

    assert 200 = result.variables.x.cost
  end
end
