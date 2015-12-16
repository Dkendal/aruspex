defmodule Aruspex.Var do
  @opaque t :: %__MODULE__{
    binding: any,
    domain: domain,
    cost: number
  }

  @type domain :: Enum.t

  defstruct binding: nil, domain: [], cost: 0

  @spec domain(t) :: domain
  def domain(var) do
    var.domain
  end
end
