defmodule D2C2 do
  alias Utils.Parser

  @zeros %{"green" => 0, "blue" => 0, "red" => 0}

  def run(ext) do
    Parser.parse("d2/#{ext}")
    |> parse_games()
    |> Enum.map(&select_highest_colors(&1))
    |> reduce_min_cubes()
  end

  def parse_games(games) do
    Enum.map(games, fn game ->
      game
      |> String.split(":")
      |> List.last()
      |> String.split(";")
      |> Enum.reduce([], fn round, acc ->
        round_results =
          round
          |> String.split(",")
          |> Enum.map(&String.trim/1)
          |> Enum.map(fn datum ->
            [num_string, color] = String.split(datum, " ")
            {num, _} = Integer.parse(num_string)
            {num, color}
          end)

        acc ++ round_results
      end)
    end)
  end

  def select_highest_colors(data) do
    Enum.reduce(data, @zeros, fn {num, color}, acc ->
      if Map.get(acc, color, 0) < num do
        Map.put(acc, color, num)
      else
        acc
      end
    end)
  end

  def reduce_min_cubes(games) do
    Enum.reduce(games, 0, fn game, acc ->
      Enum.reduce(Map.values(game), 1, &Kernel.*/2) + acc
    end)
  end
end
