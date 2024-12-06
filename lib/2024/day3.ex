defmodule Day3 do
  import Utils.Parser

  def run_part1(file) do
    read("day3/#{file}", "2024")
    |> Enum.reduce(0, &match_all_pattern(&1) + &2)
    |> then(&IO.puts(inspect(&1)))
  end

  def run_part2(file) do
    read("day3/#{file}", "2024")
    |> Enum.map(&remove_donts/1)
    |> Enum.reduce(0, &match_all_pattern(&1) + &2)
    |> then(&IO.puts(inspect(&1)))
  end

  @pattern ~r/mul\((-?\d+),(-?\d+)\)/

  defp match_all_pattern(string) do
    @pattern
    |> Regex.scan(string)
    |> Enum.reduce(0, fn match, acc ->
      [a, b] = match
      |> List.delete_at(0)
      |> Enum.map(&get_int/1)

      a * b + acc
    end)
  end

  defp remove_donts(string) do
    ~r/do/
    |> Regex.split(string)
    |> Enum.reject(&Regex.match?(~r/^n't()/, &1))
    |> Enum.filter(&Regex.match?(~r/^()/, &1))
    |> Enum.join("")
  end
end
