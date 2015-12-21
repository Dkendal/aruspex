defmodule Examples.MapColouring do
  defmacro test strategy do
    quote do
      test "#{inspect unquote strategy} solves map colouring" do
        import Aruspex.Server
        use Aruspex.Constraint

        {:ok, problem} = start_link

        variables = [
          wa  = :western_australia,
          nt  = :nothern_territory,
          q   = :queensland,
          sa  = :south_australia,
          nsw = :new_south_wales,
          v   = :victoria,
          t   = :tasmania
        ]

        domain = [:red, :green, :blue]

        Enum.map variables, &(variable problem, &1, domain)

        problem
        |> set_search_strategy(unquote strategy)
        # adjacent territories cannot be the same colour
        |> post(linear ^wa != ^nt)
        |> post(linear ^wa != ^sa)
        |> post(linear ^sa != ^nt)
        |> post(linear ^sa != ^q)
        |> post(linear ^sa != ^nsw)
        |> post(linear ^sa != ^v)
        |> post(linear ^nt != ^q)
        |> post(linear ^q != ^nsw)
        |> post(linear ^nsw != ^v)
        |> find_solution

        # minimum colouring is 3, a value greater than three indicates that a
        # hard constraint was violated
        # TODO replace this with a constrained variable and clearer validity
        # checking
        cost = Aruspex.State.get_cost :sys.get_state problem
        assert cost == 0
      end
    end
  end
end
