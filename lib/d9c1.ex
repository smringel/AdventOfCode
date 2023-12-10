defmodule D9C1 do
  alias Utils.Parser

  def run(ext) do
    data = Parser.parse("d9/#{ext}")

    data
    |> parse_histories()
    |> Enum.map(&sequence(&1, [], [&1]))
    |> Enum.map(&update_history/1)
    |> Enum.sum()
  end

  def parse_histories(data) do
    Enum.map(data, fn string ->
      string
      |> String.split(" ")
      |> Enum.map(&Parser.get_int/1)
    end)
  end

  def sequence([a, b | tl], row_acc, acc), do: sequence([b | tl], row_acc ++ [b - a], acc)

  def sequence(_, row_acc, acc) do
    history_acc = acc ++ [row_acc]

    if Enum.all?(row_acc, &(&1 == 0)) do
      history_acc
    else
      sequence(row_acc, [], history_acc)
    end
  end

  def update_history(sequence), do: Enum.reduce(sequence, 0, &(List.last(&1) + &2))
end
