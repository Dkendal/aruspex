defmodule Aruspex.Logger do
  def log_stats([]), do: :ok

  def log_stats([eval | t]) do
    require Logger

    %{
      "binding" => pretty(eval.binding, "::=", :rjust, 1),
      "complete" => eval.complete?,
      "cost breakdown" => eval.cost,
      "number of iterations" => eval.step,
      "total cost" => eval.total_cost,
      "total violations" => eval.total_violations,
      "valid" => eval.valid?,
      "violation breakdown" => eval.violations
    }
    |> pretty
    |> Logger.debug

    log_stats(t)
  end

  defp pretty(h, d \\ "=", f \\ :ljust, indent_level \\ 0)

  defp pretty(h, _d, _f, _i) when h == %{}, do: inspect %{}

  defp pretty([{_, _} | _] = h, d, f, i), do: Enum.into(h, %{}) |> pretty(d, f, i)

  defp pretty(h, d, f, indent_level) when is_map(h) do
    "\n" <> Enum.map_join h, "\n", fn {k, v} ->
      "#{
        String.duplicate("\t", indent_level)
      }#{
        apply String, f, [to_string(k), padding(h)]
      } #{d} #{
        pretty v, d, f, indent_level + 1
      }"
    end
  end

  defp pretty(h, _f, _d, _i), do: h

  defp padding(h) do
    l = h
        |> Dict.keys
        |> Enum.max
        |> inspect
        |> String.length
    l - 1
  end
end
