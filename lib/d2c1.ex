defmodule D2C1 do
  alias Utils.Parser

  def run(ext) do
    Parser.parse("d2/#{ext}")
    |> parse_games() |> IO.inspect(label: "")
    |> Enum.map(&select_highest_colors(&1))
  end

  def parse_games(games) do
    Enum.map(games, fn game ->
      [id_string, results_string] = game
        |> String.split(":")

      {id, _} = id_string
        |> String.graphemes()
        |> List.last()
        |> Integer.parse()

      rounds = results_string
      |> String.split(";")
      |> Enum.reduce([], fn round, acc ->
        round_results = round
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

  def select_highest_colors({_id, data}) do
    Enum.reduce(data, %{}, fn {num, color}, acc ->
      IO.inspect(acc, label: "acc")
      if Map.get(acc, color, 0) < num do
        Map.put(acc, color, num)
      else
        acc
      end
    end)
  end
end
