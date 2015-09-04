defmodule Aruspex.Strategy do
  use Behaviour
  alias Aruspex.State

  @doc "Binds values to variables that statisfy defined constraints."
  defcallback label(state :: State) :: State
end
