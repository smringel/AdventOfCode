defmodule D10C1 do
  alias Utils.Parser

  @symbols ["-", "|", "F", "7", "J", "L"]
  @horizontal_symbols @symbols -- ["|"]
  @vertical_symbols @symbols -- ["-"]
  def run(ext) do
    map = Parser.parse("d10/#{ext}")
    |> Enum.map(&String.graphemes/1)
    {start_x, start_y} = closed_list = find_start(map)
    x_bound = length(Enum.at(map, 0))
    y_bound = length(map)
    map_neighbors({start_x, start_y, "S"}, 1, {x_bound, y_bound}, map, [closed_list])
  end

  @spec find_start(any) :: {nil | non_neg_integer, non_neg_integer}
  def find_start(map) do
    y = Enum.find_index(map, fn row ->
      Enum.any?(row, & &1 == "S")
    end)
    x = Enum.find_index(Enum.at(map, y), & &1 == "S")
    {x, y}
  end

  def map_neighbors(locs, count, {x_bound, y_bound}, map, closed_list) do
    if eq?(locs) do
      count
    else
      next_neighbors = Enum.map(locs, &next_neighbor(&1, {x_bound, y_bound}, map))
    end
  end

  def map_neighbors({x, y, "S"}, count, {x_bound, y_bound}, map, closed_list) do
    neighbors = cond do
       x == 0 and y == 0 -> [{1, 0}, {0, 1}]
       x == x_bound and y == y_bound -> [{x_bound - 1, 0}, {0, y_bound - 1}]
      true ->
        hori_neighbors = Enum.filter([{x - 1, y}, {x + 1, y}], fn point ->
          symbol(point, map) in @horizontal_symbols
        end)
        vert_neighbors = Enum.filter([{x, y - 1}, {x, y + 1}], fn point ->
          symbol(point, map) in @vertical_symbols
        end)
        hori_neighbors ++ vert_neighbors
    end
    neighbors
    |> Enum.map(&symbol(&1, map))
    |> map_neighbors(count + 1, {x_bound, y_bound}, map, closed_list ++ neighbors)
  end

  def next_neighbor({x, y, "-"}, {x_bound, y_bound}, map) do
    if x - 1 >= 0
  end

  def closed?(point, closed_list), do: point in closed_list
  def eq?([a, b]), do: a == b
  def symbol({x, y}, map), do: map |> Enum.at(y) |> Enum.at(x)
end
