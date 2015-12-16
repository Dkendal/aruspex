defmodule Aruspex.Case do
  use ExUnit.CaseTemplate

  using do
    quote do
      use ExSpec
    end
  end
end
