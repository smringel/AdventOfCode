defmodule D8C1 do
  alias Utils.Parser

  def run(ext) do
    [direction_string | raw_nodes] = Parser.parse("d8/#{ext}")
    directions = String.graphemes(direction_string)
    nodes = parse_nodes(raw_nodes)

    traverse_nodes(directions, nodes, "AAA", 0)
  end

  def parse_nodes(nodes) do
    Enum.map(nodes, fn string ->
      [parent, children_string] = String.split(string, " = ")

      [left_child, right_child] =
        children_string
        |> String.split(", ")
        |> Enum.map(&(String.replace(&1, "(", "") |> String.replace(")", "")))
        |> List.flatten()

      {parent, left_child, right_child}
    end)
  end

  def traverse_nodes(_directions, _nodes, "ZZZ", steps), do: steps

  def traverse_nodes(directions, nodes, cur_node, steps) do
    {_node, l, r} = Enum.find(nodes, fn {node, _l, _r} -> node == cur_node end)

    [dir | tl_dirs] = directions
    next_directions = tl_dirs ++ [dir]

    next_node =
      if dir == "L" do
        l
      else
        r
      end

    traverse_nodes(next_directions, nodes, next_node, steps + 1)
  end
end
