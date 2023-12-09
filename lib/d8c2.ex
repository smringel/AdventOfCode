defmodule D8C2 do
  alias Utils.Parser

  def run(ext) do
    [direction_string | raw_nodes] = Parser.parse("d8/#{ext}")
    directions = String.graphemes(direction_string)
    nodes = parse_nodes(raw_nodes)
    starting_nodes = Enum.filter(nodes, fn {node, _l, _r} ->
      String.last(node) == "A"
    end)
    Enum.map(starting_nodes, &traverse_nodes(directions, nodes, &1, 0))
    |> Enum.reduce(&lcm(&1, &2))
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

  def traverse_nodes(directions, nodes, cur_node, steps) do
    {node, l, r} = cur_node
    if String.last(node) == "Z" do
      steps
    else

      [dir | tl_dirs] = directions
      next_directions = tl_dirs ++ [dir]

      next =
        if dir == "L" do
          l
        else
          r
        end
      next_node = Enum.find(nodes, fn {node, _l, _r} -> node == next end)
      traverse_nodes(next_directions, nodes, next_node, steps + 1)
    end
  end

  def gcd(a, 0), do: a
	def gcd(0, b), do: b
	def gcd(a, b), do: gcd(b, rem(round(a),round(b)))

  def lcm(0, 0), do: 0
	def lcm(a, b), do: round((a*b)/gcd(a,b))
end
