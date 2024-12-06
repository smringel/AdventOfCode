defmodule Day4 do
  import Utils.Parser

  def run_part1(file) do
    read("day3/#{file}", "2024")
    |> then(&IO.puts(inspect(&1)))
  end

  def run_part2(file) do
    read("day3/#{file}", "2024")
    |> then(&IO.puts(inspect(&1)))
  end
end
