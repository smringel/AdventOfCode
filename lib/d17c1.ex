defmodule D17C1 do
  alias Utils.Parser

  @directions [{-1, 0}, {1, 0}, {0, -1}, {0, 1}]

  def run(ext) do
    map = Parser.parse("d17/#{ext}")
    |> Enum.map(fn string ->
      String.graphemes(string) |> Enum.map(&Parser.get_int/1)
    end)

    start = {0, 0}
    goal = {length(hd(map)) - 1, length(map) - 1}
    history = :gb_sets.singleton({0, {start, 0, {-1, -1}}})
    bfs(history, map, goal, MapSet.new())
  end

  def bfs(history, map, goal, closed_list) do
    {smallest, h} = :gb_sets.take_smallest(history)
    {loss, {{x, y} = pos, steps, dir}} = smallest
    if pos == goal do
      loss
    else
      neighbors = @directions
      |> Enum.flat_map(fn {dx, dy} = next_dir ->
        next_pos = {x + dx, y + dy}
        cond do
          out_of_bounds?(next_pos, map) -> []
          dir == next_dir and steps >= 3 -> []
          dir == next_dir -> [{next_pos, steps + 1, dir}]
          dir == {-dx, -dy} -> []
          true -> [{next_pos, 1, next_dir}]
        end
      end)
      |> Enum.reject(&MapSet.member?(closed_list, &1))

      updated_closed_list = Enum.reduce(neighbors, closed_list, fn neighbor, acc ->
        MapSet.put(acc, neighbor)
      end)

      updated_history = Enum.reduce(neighbors, h, fn {{next_x, next_y}, _, _} = elem, acc ->
        next_loss = loss + (map |> Enum.at(next_y) |> Enum.at(next_x))
        :gb_sets.insert({next_loss, elem}, acc)
      end)

      bfs(updated_history, map, goal, updated_closed_list)
    end
  end

  def out_of_bounds?({x, y}, map) do
    x < 0 or y < 0 or x >= length(hd(map)) or y >= length(map)
  end
end
