defmodule Aruspex.Util do
  defmacro __using__(_) do
    quote do
      import Aruspex.Util
      require Aruspex.Util
    end
  end

  defmacro z g do
    quote do
      z_combinator fn var!(this) ->
        unquote(g)
      end
    end
  end

  #λf. (λx. f (λy. x x y)) (λx. f (λy. x x y))
  def z_combinator f do
    combinator = fn(x) ->
      f.(fn(y) -> x.(x).(y) end)
    end

    combinator.(combinator)
  end
end
