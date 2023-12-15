defmodule D14C2 do
  alias Utils.Parser

  @cycles 1_000_000_000

  def run(ext) do
    Parser.parse("d14/#{ext}")
    |> Enum.map(&String.graphemes/1)
    |> find_cycle()
    |> select_map()
    |> weigh()
  end

  def find_cycle(map) do
    Enum.reduce_while(1..@cycles, {nil, nil, [map]}, fn x, {_, _, prev_maps} ->
      next = spin_cycle(List.last(prev_maps))
      case Enum.find_index(prev_maps, fn map -> map == next end) do
        nil -> {:cont, {nil, nil, prev_maps ++ [next]}}
        index -> {:halt, {x, index, prev_maps}}
      end
    end)
  end

  def select_map({x, cycle_start_x, maps}) do
    cycle_length = x - cycle_start_x
    remaining = @cycles - cycle_start_x
    map_index = rem(remaining, cycle_length) + cycle_start_x
    Enum.at(maps, map_index)
  end

  def spin_cycle(map) do
    map
    |> tilt_north()
    |> tilt_west()
    |> tilt_south()
    |> tilt_east()
  end

  def tilt_north(map) do
    map
    |> transpose()
    |> tilt()
    |> transpose()
  end

  def tilt_west(map) do
    tilt(map)
  end

  def tilt_south(map) do
    map
    |> transpose()
    |> Enum.map(&Enum.reverse/1)
    |> tilt()
    |> Enum.map(&Enum.reverse/1)
    |> transpose()
  end

  def tilt_east(map) do
    map
    |> Enum.map(&Enum.reverse/1)
    |> tilt()
    |> Enum.map(&Enum.reverse/1)
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

  def tilt_row([a], acc), do: acc ++ [a] |> List.flatten() |> Enum.join()

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
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&Enum.join/1)
    |> Enum.map(&String.graphemes/1)
  end
end
