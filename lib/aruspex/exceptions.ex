defmodule Aruspex.Strategy.InvalidResultError do
  defexception [:module]
  def message e do
    "Strategy #{e.module}'s call to label/2 failed to produce a valid assignment"
  end
end
