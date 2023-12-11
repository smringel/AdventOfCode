defmodule D10C1 do
  alias Utils.Parser

  @symbols ["-", "|", "F", "7", "J", "L"]
  @horizontal_symbols @symbols -- ["|"]
  @vertical_symbols @symbols -- ["-"]
  @nav_dict %{
    "-" => ["e", "w"],
    "|" => ["n", "s"],
    "L" => ["n", "e"],
    "J" => ["n", "w"],
    "7" => ["s", "w"],
    "F" => ["s", "e"],
    "." => []
  }

  def run(ext) do
    map = Parser.parse("d10/#{ext}")
    |> Enum.map(&String.graphemes/1)
    start_loc = find_start(map) |> IO.inspect(label: "start")
    x_bound = length(Enum.at(map, 0))
    y_bound = length(map)
    starting_neighbor = map_neighbors(start_loc, {x_bound, y_bound}, map)
    navigate(starting_neighbor, 1, map)
  end

  def find_start(map) do
    y = Enum.find_index(map, fn row ->
      Enum.any?(row, & &1 == "S")
    end)
    x = Enum.find_index(Enum.at(map, y), & &1 == "S")
    {x, y}
  end

  def navigate({x, y, from_dir, sym}, count, map) do
    next_dir = @nav_dict
    |> Map.get(sym)
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
      round(count / 2)
    else
      navigate({next_x, next_y, next_from, next_symbol}, count + 1, map)
    end
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
          |> then(&Map.get(@nav_dict, &1))
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

  def symbol({x, y}, map), do: map |> Enum.at(y) |> Enum.at(x)
end
