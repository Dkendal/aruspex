defprotocol Aruspex.Strategy do
  alias Aruspex.State
  @type t :: __MODULE__.t

  @spec do_iterator(t, State.t, pid) :: Enumerable.t
  def do_iterator(strat, state, caller)
end
