defmodule D13C1 do
  alias Utils.Parser

  def run(ext) do
    Parser.parse("d13/#{ext}", false)
    |> get_maps([])
    |> Enum.map(&find_reflections(&1))
    |> Enum.sum()
  end

  def get_maps(data, acc) do
    data
    |> Enum.find_index(& &1 == "")
    |> case do
      nil -> acc ++ [data]
      index -> {map, rest} = Enum.split(data, index)
      get_maps(Enum.drop(rest, 1), acc ++ [map])
    end
  end

  def find_reflections(map) do
    horizontal_score =
      case find_mirror(map) do
        nil -> 0
        index -> index * 100
      end

    vertical_score =
      map
      |> transpose()
      |> find_mirror()
      |> case do
        nil -> 0
        index -> index
      end

    horizontal_score + vertical_score
  end

  def find_mirror(map) do
    Enum.find(1..length(map) - 1, fn x ->
      {above, below} = Enum.split(map, x)
      cond do
        length(above) > length(below) ->
          above
          |> Enum.slice(-length(below)..-1)
          |> Enum.reverse()
          |> Kernel.==(below)

        length(above) < length(below) ->
          below
          |> Enum.take(x)
          |> Enum.reverse()
          |> Kernel.==(above)

        true -> above |> Enum.reverse() |> Kernel.==(below)
      end
    end)
  end

  def transpose(map) do
    map
    |> Enum.map(&String.graphemes/1)
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&Enum.join/1)
  end
end
