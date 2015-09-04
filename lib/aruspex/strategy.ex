defmodule Aruspex.Strategy do
  use Behaviour

  @doc "Binds values to variables that statisfy defined constraints."
  defcallback label(state :: Aruspex.State) :: Aruspex.State
end
