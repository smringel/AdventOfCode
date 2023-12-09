defmodule D8C2 do
  alias Utils.Parser

  def run(ext) do
    [direction_string | raw_nodes] = Parser.parse("d8/#{ext}")
    directions = String.graphemes(direction_string)
    nodes = parse_nodes(raw_nodes)
    starting_nodes = Enum.filter(nodes, fn {node, _l, _r} ->
      String.last(node) == "A"
    end)

    traverse_nodes(directions, nodes, starting_nodes, 0)
  end

  def parse_nodes(nodes) do
    Enum.map(nodes, fn string ->
      [parent, children_string] = String.split(string, " = ")
      [left_child, right_child] = children_string
        |> String.split(", ")
        |> Enum.map(&String.replace(&1, "(", "") |> String.replace(")", ""))
        |> List.flatten()
      {parent, left_child, right_child}
    end)
  end

  def traverse_nodes(directions, nodes, cur_nodes, steps) do
    cur_nodes
      |> Enum.all?(fn {node, _l, _r} -> String.last(node) == "Z" end)
      |> if do
        steps
      else
        [dir | tl_dirs] = directions
        next_directions = tl_dirs ++ [dir]
        next_nodes = Enum.map(cur_nodes, &traverse_node(&1, nodes, dir))
        traverse_nodes(next_directions, nodes, next_nodes, steps + 1)
      end
    end

  def traverse_node(cur_node, nodes, dir) do
    {_node, l, r} = cur_node
    next_node = if dir == "L", do: l, else: r

    Enum.find(nodes, fn {node, _l, _r} -> node == next_node end)
  end
end
