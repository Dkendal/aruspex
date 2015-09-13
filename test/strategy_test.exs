defmodule Aruspex.StrategyTest do
  defmacro __using__ strategy: strategy do
    quote do
      setup do
        n = 4
        strategy = unquote strategy

        {:ok, pid} = Aruspex.start_link

        for x <- 1..n, do:
        Aruspex.variable(pid, x, (for y <- 1..n, do: {x, y}))
        :ok = Aruspex.set_search_strategy pid, strategy

        for_all pid, fn
          (s, s) -> 1
          ({s, _x2}, {s, _y2}) -> 1
          ({_x1, s}, {_y1, s}) -> 1
          ({x1, x2}, {y1, y2}) when x1+x2 == y1+y2 -> 1
          ({x1, x2}, {y1, y2}) when x1-x2 == y1-y2 -> 1
          (_, _) -> 0
        end

        solution = Aruspex.find_solution pid

        {:ok, solution: solution, pid: pid }
      end

      test "#{unquote strategy} can solve #{4} queens", %{solution: solution} do
        case solution[1] do
          {1,3} ->
            assert solution[1] == {1,3}
            assert solution[2] == {2,1}
            assert solution[3] == {3,4}
            assert solution[4] == {4,2}

          {1,2} ->
            assert solution[1] == {1,2}
            assert solution[2] == {2,4}
            assert solution[3] == {3,1}
            assert solution[4] == {4,3}
        end
      end
    end
  end
end
