defmodule D10C2 do
  alias Utils.Parser

  @nav_dict %{
    "-" => ["e", "w"],
    "|" => ["n", "s"],
    "L" => ["n", "e"],
    "J" => ["n", "w"],
    "7" => ["s", "w"],
    "F" => ["s", "e"]
  }
  @north_symbols ["|", "F", "7"]
  @south_symbols ["|", "J", "L"]
  @east_symbols ["-", "J", "7"]
  @west_symbols ["-", "F", "L"]

  def run(ext) do
    map = Parser.parse("d10/#{ext}")
    |> Enum.map(&String.graphemes/1)

    start_loc = find_start(map)
    x_bound = length(Enum.at(map, 0))
    y_bound = length(map)

    {x, y, _from_dir, _symbol} = starting_neighbor = map_neighbors(start_loc, {x_bound, y_bound}, map)

    closed_list = navigate(starting_neighbor, 1, map, [{x, y}])

    map
    |> clean_map(x_bound, y_bound, closed_list)
    |> add_start(start_loc)
    |> count_enclosed()
  end

  def find_start(map) do
    y = Enum.find_index(map, fn row ->
      Enum.any?(row, & &1 == "S")
    end)
    x = Enum.find_index(Enum.at(map, y), & &1 == "S")
    {x, y}
  end

  def navigate({x, y, from_dir, sym}, count, map, acc) do
    next_dir = @nav_dict
    |> Map.get(sym, [])
    |> Enum.reject(& &1 == from_dir)
    |> List.first()

    {next_x, next_y, next_from} =
      case next_dir do
        "n" -> north({x, y})
        "s" -> south({x, y})
        "e" -> east({x, y})
        "w" -> west({x, y})
      end

    next_symbol = symbol({next_x, next_y}, map)

    if next_symbol == "S" do
      acc
    else
      navigate({next_x, next_y, next_from, next_symbol}, count + 1, map, acc ++ [{next_x, next_y}])
    end
  end

  def clean_map(map, x_bound, y_bound, closed_list) do
    Enum.reduce(0..y_bound - 1, map, fn y, map_acc ->
      row = Enum.at(map, y)
      new_row = Enum.reduce(0..x_bound - 1, row, fn x, row_acc ->
        if {x, y} not in closed_list, do: List.replace_at(row_acc, x, "."), else: row_acc
      end)
      List.replace_at(map_acc, y, new_row)
    end)
  end

  def add_start(map, {start_x, start_y} = loc) do
    start_symbol = [north(loc), south(loc), east(loc), west(loc)]
    |> Enum.map(fn {x, y, _} -> map |> Enum.at(y) |> Enum.at(x) end)
    |> get_symbol_from_neighbors()

    Enum.at(map, start_y)
    |> List.replace_at(start_x, start_symbol)
    |> then(&List.replace_at(map, start_y, &1))
  end

  def count_enclosed(map) do
    map
    |> List.flatten()
    |> Enum.reduce({0, nil, false}, fn val, {count, entry, inside?} = acc ->
      case {entry, val} do
        {entry, "."} -> if inside?, do: {count + 1, entry, inside?}, else: acc
        # Staying on same side of shape boundary
        {"F", "J"} -> {count, nil, inside?}
        {"L", "7"} -> {count, nil, inside?}
        {_entry, "-"} -> acc
        # Crossing shape boundary
        {"F", "7"} -> {count, nil, not inside?}
        {"L", "J"} -> {count, nil, not inside?}
        {_entry, sym} -> {count, sym, not inside?}
      end
    end)
    |> elem(0)
  end

  def north({x, y}), do: {x, y - 1, "s"}
  def south({x, y}), do: {x, y + 1, "n"}
  def east({x, y}), do: {x + 1, y, "w"}
  def west({x, y}), do: {x - 1, y, "e"}

  def map_neighbors({x, y} = loc, {x_bound, y_bound}, map) do
    cond do
      x == 0 and y == 0 -> {1, 0, "w"}
      x == x_bound and y == y_bound -> {x_bound - 1, 0, "e"}
      true ->
        {next_x, next_y, from_dir} = loc
        |> get_neighbors(x_bound, y_bound)
        |> Enum.filter(fn {x, y, from_dir} ->
          {x, y}
          |> symbol(map)
          |> then(&Map.get(@nav_dict, &1, []))
          |> Enum.reject(& &1 == from_dir)
          |> then(&length(&1) == 1)
        end)
        |> List.first()
        {next_x, next_y, from_dir, symbol({next_x, next_y}, map)}
    end
  end

  def get_neighbors(loc, x_bound, y_bound) do
    [north(loc), south(loc), east(loc), west(loc)]
    |> Enum.filter(fn {x, y, _from_dir} -> x >= 0 and y >= 0 and x <= x_bound and y <= y_bound end)
  end

  def get_symbol_from_neighbors([north, south, _, _]) when north in @north_symbols and south in @south_symbols, do: "|"
  def get_symbol_from_neighbors([north, _, east, _]) when north in @north_symbols and east in @east_symbols, do: "L"
  def get_symbol_from_neighbors([north, _, _, west]) when north in @north_symbols and west in @west_symbols, do: "J"
  def get_symbol_from_neighbors([_, south, east, _]) when south in @south_symbols and east in @east_symbols, do: "F"
  def get_symbol_from_neighbors([_, south, _, west]) when south in @south_symbols and west in @west_symbols, do: "7"
  def get_symbol_from_neighbors([_, _, east, west]) when east in @east_symbols and west in @west_symbols, do: "-"

  def symbol({x, y}, map), do: map |> Enum.at(y) |> Enum.at(x)
end
