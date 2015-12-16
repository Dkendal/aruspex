defmodule Aruspex.StrategyCase do
  use ExUnit.CaseTemplate

  using strategy: strategy do
    quote do
      require Examples.FourQueens
      require Examples.MapColouring

      Examples.FourQueens.test(unquote strategy)
      Examples.MapColouring.test(unquote strategy)
    end
  end
end
