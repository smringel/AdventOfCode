defmodule Day2 do
  import Utils.Parser

  def run_part1(file) do
    read("day2/#{file}", "2024")
    |> compile_reports()
    |> Enum.count(&monotonic?(&1))
    |> then(&IO.puts(inspect(&1)))
  end

  def run_part2(file) do
    read("day2/#{file}", "2024")
    |> compile_reports()
    |> Enum.count(&monotonic_with_removal?(&1))
    |> then(&IO.puts(inspect(&1)))
  end

  defp compile_reports(string_array) do
    string_array
    |> Enum.map(fn report_string ->
      report_string
      |> String.split(" ")
      |> Enum.map(& get_int(&1))
    end)
  end

  defp monotonic?(list) do
    ascending?(list) or descending?(list)
  end

  defp monotonic_with_removal?(list) do
    0..length(list)
    |> Enum.map(&List.delete_at(list, &1))
    |> Enum.any?(&(ascending?(&1) or descending?(&1)))
  end

  defp ascending?([hd, second | tl]), do: ascending?([second] ++ tl, within_limit?(second - hd))
  defp ascending?([hd, tl], true), do: within_limit?(tl - hd)
  defp ascending?([hd, second | tl], true), do: ascending?([second] ++ tl, within_limit?(second - hd))
  defp ascending?(_, false), do: false

  defp descending?([hd, second | tl]), do: descending?([second] ++ tl, within_limit?(hd - second))
  defp descending?([hd, tl], true), do: within_limit?(hd - tl)
  defp descending?([hd, second | tl], true), do: descending?([second] ++ tl, within_limit?(hd - second))
  defp descending?(_, false), do: false

  defp within_limit?(val), do: 0 < val and val < 4
end
