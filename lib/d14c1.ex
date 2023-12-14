defmodule D14C1 do
  alias Utils.Parser

  def run(ext) do
    Parser.parse("d14/#{ext}", false)
    |> roll_north()
    |> weigh()
  end

  def roll_north(map) do
    map
    |> transpose()
    |> Enum.map(&Enum.chunk_by(&1, fn val -> val end))
    |> Enum.reduce([], fn row, acc ->
      acc ++ [roll_row(row, [])]
    end)
    |> transpose()
  end

  def roll_row([a, b | tl], acc) do
    cond do
      hd(a) == hd(b) -> roll_row([a ++ b | tl], acc)
      hd(a) == "." and hd(b) == "O" -> roll_row([a | tl], acc ++ [b])
      true -> roll_row([b | tl], acc ++ [a])
    end
  end

  def roll_row([a], acc), do: acc ++ [a] |> List.flatten() |> Enum.join()

  def weigh(map) do
    max = length(map)
    
    map
    |> Enum.with_index(&{max - &2, &1})
    |> Enum.reduce(0, fn {weight, row}, acc ->
      acc + Enum.count(row, & &1 == "O") * weight
    end)
  end

  def transpose(map) do
    map
    |> Enum.map(&String.graphemes/1)
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&Enum.join/1)
    |> Enum.map(&String.graphemes/1)
  end
end
