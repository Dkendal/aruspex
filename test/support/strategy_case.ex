defmodule Aruspex.StrategyCase do
  use ExUnit.CaseTemplate

  using strategy: strategy do
    quote do
      require Examples.FourQueens

      Examples.FourQueens.test(unquote strategy)
    end
  end
end
