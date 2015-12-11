defmodule Aruspex.StrategyTest do
  defmacro __using__ strategy: strategy do
    quote do
      setup do
        use Aruspex.Constraint

        strategy = unquote strategy
        variables = 1..4

        {:ok, pid} = Aruspex.start_link

        for x <- variables, do: Aruspex.variable(pid, x, variables)

        pid
        |> Aruspex.set_search_strategy(strategy)
        |> Aruspex.post(all_diff variables)

        for x <- variables, y <- variables, y > x do
          pid
          |> Aruspex.post(linear x + ^x != y + ^y)
          |> Aruspex.post(linear x - ^x != y - ^y)
        end

        solution = Aruspex.find_solution pid

        {:ok, solution: solution, pid: pid }
      end

      test "#{unquote strategy} can solve #{4} queens", %{solution: solution} do
        case solution[1] do
          3 ->
            assert solution[1] == 3
            assert solution[2] == 1
            assert solution[3] == 4
            assert solution[4] == 2

          2 ->
            assert solution[1] == 2
            assert solution[2] == 4
            assert solution[3] == 1
            assert solution[4] == 3

          s ->
            flunk "didn't find a solution: #{inspect s}"
        end
      end
    end
  end
end
