defmodule Aruspex.Strategy do
  use Behaviour
  @type options :: Keyword.t
  @type solution_iterator :: Enumerable.t
  defcallback set_strategy(Problem.t, options) :: solution_iterator

  defmacro __using__([]) do
    quote do
      def member?(_, _), do: {:error, __MODULE__}
      def count(_), do: {:error, __MODULE__}
    end
  end
end
