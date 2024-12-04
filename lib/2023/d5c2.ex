defmodule D5C2 do
  alias Utils.Parser

  def run(ext) do
    [seed_data | map_data] = Parser.parse("d5/#{ext}")

    seed_ranges =
      get_seeds(seed_data)
      |> Enum.chunk_every(2)
      |> Enum.map(fn [min, range] -> {min, min + range - 1} end)

    dicts = get_dicts(map_data)

    seed_ranges
    |> Enum.flat_map(&translate(&1, dicts[:seed]))
    |> Enum.flat_map(&translate(&1, dicts[:soil]))
    |> Enum.flat_map(&translate(&1, dicts[:fertilizer]))
    |> Enum.flat_map(&translate(&1, dicts[:water]))
    |> Enum.flat_map(&translate(&1, dicts[:light]))
    |> Enum.flat_map(&translate(&1, dicts[:temperature]))
    |> Enum.flat_map(&translate(&1, dicts[:humidity]))
    |> Enum.map(&elem(&1, 0))
    |> Enum.min()
  end

  def translate([_ | _] = input_ranges, dict),
    do: Enum.map(input_ranges, &translate(&1, dict)) |> List.flatten()

  def translate({min, max} = input_range, dict) do
    min_src = Enum.map(dict, & &1[:src]) |> Enum.min()
    max_src = Enum.map(dict, &(&1[:src] + &1[:range] - 1)) |> Enum.max()

    if max < min_src or min > max_src do
      List.wrap(input_range)
    else
      build_ranges(input_range, min_src, max_src, dict, [])
    end
  end

  def build_ranges({min, max}, min_src, max_src, dict, acc) do
    acc
    |> maybe_add_low_range(min, min_src)
    |> maybe_add_high_range(max, max_src)
    |> add_intersection_range(max(min, min_src), min(max, max_src), dict)
  end

  def maybe_add_low_range(acc, min, min_src) when min < min_src, do: acc ++ [{min, min_src - 1}]
  def maybe_add_low_range(acc, _, _), do: acc

  def maybe_add_high_range(acc, max, max_src) when max > max_src, do: acc ++ [{max_src + 1, max}]
  def maybe_add_high_range(acc, _, _), do: acc

  def add_intersection_range(acc, min, max, dict) do
    Enum.reduce(dict, acc, fn %{src: src, dest: dest, range: range}, out_acc ->
      cond do
        # if higher than a dict row, no op
        min > src + range ->
          out_acc

        # if fully encompassed by a dict row, increment by the difference
        min >= src and max < src + range ->
          diff = dest - src
          out_acc ++ [{min + diff, max + diff}]

        # if extends beyond range of dict row, split range
        # partially increment the encompassed part, recalc the rest
        min >= src and max > src + range ->
          diff = dest - src
          partial_update_acc = out_acc ++ [{min + diff, dest + range}]

          updated_dict =
            Enum.find_index(dict, &(&1[:src] == src))
            |> then(&List.delete_at(dict, &1))

          add_intersection_range(partial_update_acc, src + range, max, updated_dict)

        true ->
          out_acc
      end
    end)
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
      [from, _to] = String.split(keystring, "-to-")

      dict =
        Enum.map(list, fn [dest, src, range] ->
          %{dest: dest, src: src, range: range}
        end)

      acc ++ [{String.to_atom(from), dict}]
    end)
  end
end
