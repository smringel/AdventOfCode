defmodule Day3 do
  import Utils.Parser

  def run_part1(file) do
    read("day3/#{file}", "2024")
    |> Enum.reduce(0, &match_pattern(&1) + &2)
    |> then(&IO.puts(inspect(&1)))
  end

  def run_part2(file) do
    read("day3/#{file}", "2024")
    |> then(&IO.puts(inspect(&1)))
  end

  defp match_pattern(string) do
    ~r/mul\((-?\d+),(-?\d+)\)/
    |> Regex.scan(string)
    |> Enum.reduce(0, fn match, acc ->
      [a, b] = match
      |> List.delete_at(0)
      |> Enum.map(&get_int/1)

      a * b + acc
    end)
  end
end
