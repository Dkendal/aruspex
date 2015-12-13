defmodule Aruspex.Matchers do
  import ExUnit.Assertions
  import IO.ANSI
  alias Macro, as: M

  def to_generate actual, expected do
    assert generate(actual, expected), generate_msg(actual, expected)
  end

  defp generate actual, expected do
    mx_str(actual) == M.to_string(expected)
  end

  defp generate_msg actual, expected do
    """
    #{white}Expected macro #{red}#{M.to_string actual}#{white} to generate:
    #{red}
    #{M.to_string expected}
    #{white}
    actual:
    #{red}
    #{mx_str actual}
    #{reset}
    """
  end

  defp mx_str(macro) do
    M.expand_once(macro, __ENV__)
    |> M.to_string
  end
end

# load me in mix.exs instead
ExUnit.start()
