defmodule D14C1 do
  alias Utils.Parser

  def run(ext) do
    Parser.parse("d14/#{ext}")
    |> Enum.map(&String.graphemes/1)
    |> tilt_north()
    |> weigh()
  end

  def tilt_north(map) do
    map
    |> transpose()
    |> tilt()
    |> transpose()
  end

  def tilt(map) do
    map
    |> Enum.map(&Enum.chunk_by(&1, fn val -> val end))
    |> Enum.reduce([], fn row, acc ->
      acc ++ [tilt_row(row, [])]
    end)
    |> Enum.map(&String.graphemes/1)
  end

  def tilt_row([a, b | tl], acc) do
    cond do
      hd(a) == hd(b) -> tilt_row([a ++ b | tl], acc)
      hd(a) == "." and hd(b) == "O" -> tilt_row([a | tl], acc ++ [b])
      true -> tilt_row([b | tl], acc ++ [a])
    end
  end

  def tilt_row([a], acc), do: (acc ++ [a]) |> List.flatten() |> Enum.join()

  def weigh(map) do
    max = length(map)

    map
    |> Enum.with_index(&{max - &2, &1})
    |> Enum.reduce(0, fn {weight, row}, acc ->
      acc + Enum.count(row, &(&1 == "O")) * weight
    end)
  end

  def transpose(map) do
    map
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&Enum.join/1)
    |> Enum.map(&String.graphemes/1)
  end
end
