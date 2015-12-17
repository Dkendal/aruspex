defmodule BackPipe do
  @moduledoc """
  A Silly little module that shows why some people shouldn't be allowed to
  write macros ;).
  """

  defmacro __using__ _ do
    quote do
      import BackPipe
      require BackPipe
    end
  end

  @doc """
  Performs the same as a |>, but places the left hand side as the
  last argument to the right hand side.

  # E.g.
    2 <|> bar(1) == bar(1, 2)
  """
  defmacro left <|> right do
    {method, context, arguments} = right
    {method, context, arguments ++ [left]}
  end
end
