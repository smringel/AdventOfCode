defmodule Day3 do
  import Utils.Parser

  def run_part1(file) do
    read("day3/#{file}", "2024")
    |> Enum.reduce(0, &match_pattern(&1) + &2)
    |> then(&IO.puts(inspect(&1)))
  end

  def run_part2(file) do
    read("day3/#{file}", "2024")
    |> Enum.reduce({[], true}, fn line, {acc, do?} ->
      {do_vals, end_do?} = remove_donts(line, do?)
      {[do_vals] ++ acc, end_do?}
    end)
    |> elem(0)
    |> Enum.reduce(0, &match_pattern(&1) + &2)
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

  defp remove_donts(string, do?) do
    split_strings = Regex.split(~r/do/, string)
    |> then(&if do?, do: &1, else: List.delete_at(&1, 0))

    do_string = split_strings
    |> Enum.reject(&Regex.match?(~r/^n't\(\)/, &1))
    |> Enum.join("")

    end_op = !Regex.match?(~r/^n't\(\)/, List.last(split_strings))

    {do_string, end_op}
  end
end
