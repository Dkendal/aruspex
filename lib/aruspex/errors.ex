defmodule Aruspex.ConstraintArgumentError do
  defexception [:binding, :variables, :message]

  def exception(value) do
    %__MODULE__{
      message: message(value[:variables], value[:binding])
    }
  end

  def message(expected, binding) do
    actual = Dict.keys binding
    unbound =
      binding
      |> Enum.filter(fn {k, v} -> v == nil end)
      |> Dict.keys
    """
    Constaint failed to be evaluated, it was defined with variables:
        #{inspect expected, pretty: true}

    But state contains:
        #{inspect actual, pretty: true}

    Missing:
        #{inspect (expected -- actual), pretty: true}

    Unbound:
        #{inspect unbound}

    Binding:
        #{inspect binding}
    """
  end
end
