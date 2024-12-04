defmodule D2C1 do
  alias Utils.Parser

  @zeros %{"green" => 0, "blue" => 0, "red" => 0}

  def run(ext) do
    Parser.parse("d2/#{ext}")
    |> parse_games()
    |> Enum.map(&select_highest_colors(&1))
    |> filter_possible_games()
    |> sum_ids()
  end

  def parse_games(games) do
    Enum.map(games, fn game ->
      [id_string, results_string] = String.split(game, ":")

      {id, _} =
        id_string
        |> String.split(" ")
        |> List.last()
        |> Integer.parse()

      rounds =
        results_string
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

      {id, rounds}
    end)
  end

  def select_highest_colors({id, data}) do
    highest_colors =
      data
      |> Enum.reduce(@zeros, fn {num, color}, acc ->
        if Map.get(acc, color, 0) < num do
          Map.put(acc, color, num)
        else
          acc
        end
      end)

    {id, highest_colors}
  end

  def filter_possible_games(games) do
    Enum.filter(games, fn {_id, scores} ->
      scores["blue"] <= 14 and
        scores["green"] <= 13 and
        scores["red"] <= 12
    end)
  end

  def sum_ids(games) do
    Enum.reduce(games, 0, fn {id, _game}, acc -> acc + id end)
  end
end
