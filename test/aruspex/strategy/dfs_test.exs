defmodule Aruspex.Strategy.DfsTest do
  use Aruspex.Case

  test "solves the map colouring problem" do
    territories = [
      :western_australia,
      :nothern_territory,
      :queensland,
      :south_australia,
      :new_south_wales,
      :victoria,
      :tasmania
    ]

    colors = [:red, :green, :blue]

    result = Examples.MapColouring.new
              |> Aruspex.Strategy.Dfs.set_strategy()
              |> Enum.take(1)
              |> hd

    assert result.valid? == true

    assert map_size(result.binding) == 7

    assert MapSet.subset?(
      MapSet.new(territories),
      MapSet.new(Dict.keys(result.binding)))

     assert MapSet.subset?(
       MapSet.new(colors),
       MapSet.new(Dict.values(result.binding)))
  end
end
