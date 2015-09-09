defmodule Aruspex.Matchers do
  import ExUnit.Assertions
  import IO.ANSI
  alias Macro, as: M

  defp generate macro, expected do
    [actual, expected] = [mx_str(macro), M.to_string(expected)]
    expected == actual
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

  def to_generate actual, expected do
    assert generate(actual, expected), generate_msg(actual, expected)
  end

  defp mx_str(macro) do
    M.expand_once(macro, __ENV__)
    |> M.to_string
  end
end

defmodule Aruspex.Case do
  defmacro __using__ opts \\ [async: true, trace: true] do
    quote do
      use Pavlov.Case, unquote(opts)
      import Pavlov.Syntax.Expect
      import Aruspex.Matchers
    end
  end
end

Pavlov.start()
ExUnit.start()
