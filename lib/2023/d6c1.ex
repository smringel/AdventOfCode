defmodule D6C1 do
  alias Utils.Parser

  def run(ext) do
    [time_string, distance_string] = Parser.parse("d6/#{ext}")
    distances = parse_vals(distance_string)

    parse_vals(time_string)
    |> Enum.map(&build_outcomes(&1))
    |> count_winners(distances)
    |> Enum.reduce(&Kernel.*/2)
  end

  def parse_vals(string) do
    string
    |> String.split(":")
    |> List.last()
    |> String.split(" ", trim: true)
    |> Enum.map(&Parser.get_int/1)
  end

  def build_outcomes(time) do
    # 0 seconds charging and full charging don't move the boat, so ignore them
    Enum.reduce(1..(time - 1), [], fn speed, acc ->
      travel_time = time - speed
      distance = travel_time * speed
      acc ++ [distance]
    end)
  end

  def count_winners(outcomes, distances) do
    Enum.reduce(0..(length(outcomes) - 1), [], fn x, acc ->
      acc ++ [Enum.count(Enum.at(outcomes, x), &(&1 > Enum.at(distances, x)))]
    end)
  end
end
