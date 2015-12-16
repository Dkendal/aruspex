defmodule Examples.FourQueens do
  defmacro test strategy do
    quote do
      test "#{inspect unquote strategy} solves 4 queens" do
        import Enum
        import Aruspex.Server
        use Aruspex.Constraint
        variables = 1..4

        {:ok, pid} = start_link

        map variables, & variable(pid, &1, variables)

        pid
        |> set_search_strategy(unquote strategy)
        |> post(all_diff variables)

        for x <- variables, y <- variables, y > x do
          pid
          |> post(linear x + ^x != y + ^y)
          |> post(linear x - ^x != y - ^y)
        end

        solution = find_solution pid

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
