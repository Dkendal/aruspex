defmodule Aruspex.Strategy.Ac3 do
  @behaviour Aruspex.Strategy

  defstruct problem: nil, timeout: 5000

  def set_strategy(problem, opts \\ []) do
    opts = Enum.into opts, %{}
    struct __MODULE__, Map.put(opts, :problem, problem)
  end

  defimpl Enumerable, for: __MODULE__ do
    use Aruspex.Strategy

    def reduce(s, {:cont, acc}, fun) do
      { :done, acc }
    end
  end
end
