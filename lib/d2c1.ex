defmodule D2C1 do
  def digest_file(filepath) do
    File.read!(filepath)
      |> String.split("\n", trim: true)
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
        |> Enum.map(&String.trim/1)
        |> Enum.reduce(%{id: id}, fn round, acc ->
          round_results = String.split(round, ",")
          Enum.reduce(round_results, acc, fn res, tmp ->
            [num, color] = String.split(res, " ")
            Map.put(tmp, String.to_atom(color), num)
          end)
        end)
        |> IO.inspect(label: "rounds")
    end)
  end

  def run do
    digest_file("lib/2023/data/d2/example.txt")
    |> parse_games()
  end

end
