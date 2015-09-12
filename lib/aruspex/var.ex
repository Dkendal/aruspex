defmodule Aruspex.Var do
  defstruct binding: nil, domain: [], cost: 0

  defimpl Inspect, for: __MODULE__ do
    import Inspect.Algebra

    def inspect var, opts do
      concat ["#Aruspex.Var<",to_doc(var.binding, opts), ">"]
    end
  end
end
