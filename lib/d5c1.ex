defmodule D5C1 do
  alias Utils.Parser

  def run(ext) do
    [seed_data | map_data] = Parser.parse("d5/#{ext}")
    seeds = get_seeds(seed_data)
    dicts = get_dicts(map_data)

    use_dict = &translate(&1, &2, dicts)

    seeds
    |> Enum.map(
      &(use_dict.(&1, "seed")
        |> use_dict.("soil")
        |> use_dict.("fertilizer")
        |> use_dict.("water")
        |> use_dict.("light")
        |> use_dict.("temperature")
        |> use_dict.("humidity"))
    )
    |> Enum.min()
  end

  def translate(x, match, dicts) do
    dict = Enum.find(dicts, &(&1[:from] == match)) |> Map.get(:dict)

    Enum.find(dict, fn %{src: src, range: range} ->
      x >= src and x <= src + range
    end)
    |> case do
      %{src: src, dest: dest} -> x - src + dest
      _ -> x
    end
  end

  def get_seeds(seed_data) do
    seed_data
    |> String.split(": ")
    |> List.last()
    |> String.split(" ")
    |> Enum.map(&Integer.parse/1)
    |> Enum.map(&elem(&1, 0))
  end

  def get_dicts(map_data) do
    map_data
    |> Enum.map(&String.split(&1, ": "))
    |> List.flatten()
    |> Enum.chunk_by(&(Integer.parse(&1) == :error))
    |> Enum.chunk_every(2)
    |> Enum.reduce(%{}, fn [[key_string], data_list], acc ->
      key = String.split(key_string, " ") |> List.first()

      data =
        data_list
        |> Enum.map(fn data_string ->
          data_string
          |> String.split(" ")
          |> Enum.map(&Integer.parse/1)
          |> Enum.map(&elem(&1, 0))
        end)

      Map.put(acc, key, data)
    end)
    |> Enum.reduce([], fn {keystring, list}, acc ->
      [from, to] = String.split(keystring, "-to-")

      dict =
        Enum.map(list, fn [dest, src, range] ->
          %{dest: dest, src: src, range: range}
        end)

      acc ++ [%{from: from, to: to, dict: dict}]
    end)
  end
end
