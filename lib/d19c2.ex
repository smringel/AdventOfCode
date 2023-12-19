defmodule D19C2 do
  alias Utils.Parser

  def run(ext) do
    data = Parser.parse("d19/#{ext}")
    parts_start = Enum.find_index(data, &String.contains?(&1, "{x="))
    {raw_rules, _raw_parts} = Enum.split(data, parts_start)

    ranges = %{x: {1, 4000}, m: {1, 4000}, a: {1, 4000}, s: {1, 4000}}
    rules = parse_rules(raw_rules)

    limit_ranges(rules, ranges, Map.get(rules, "in"), [])
    |> Enum.map(&Map.values/1)
    |> Enum.reduce(0, fn [{x1, x2}, {m1, m2}, {a1, a2}, {s1, s2}], acc ->
      acc + ((x2 - x1 + 1) * (m2 - m1 + 1) * (a2 - a1 + 1) * (s2 - s1 + 1))
    end)
  end

  def limit_ranges(_rules, ranges, [{_, :eq, _, "A"}], _acc), do: ranges
  def limit_ranges(_rules, _ranges, [{_, :eq, _, "R"}], _acc), do: []
  def limit_ranges(rules, ranges, rule_set, acc) do
    [{key, op, comp, dest} | rest] = rule_set

    if op == :eq do
      limit_ranges(rules, ranges, Map.get(rules, dest), acc)
    else
      {pass_ranges, fail_ranges} =
        case op do
          :lt -> {min, max} = Map.get(ranges, key)
            updated_max = min(max, comp)
            if updated_max > min do
              {
                Map.put(ranges, key, {min, updated_max - 1}),
                Map.put(ranges, key, {updated_max, max})
              }
            else
              {ranges, ranges}
            end
          :gt -> {min, max} = Map.get(ranges, key)
            updated_min = max(min, comp)
            if updated_min < max do
              {
                Map.put(ranges, key, {updated_min + 1, max}),
                Map.put(ranges, key, {min, updated_min})
              }
            else
              {ranges, ranges}
            end
        end

      default = [{nil, :eq, nil, dest}]
      pass = limit_ranges(rules, pass_ranges, Map.get(rules, dest, default), acc)
      fail = limit_ranges(rules, fail_ranges, rest, acc)

      acc ++ [pass, fail] |> List.flatten()
    end
  end

  def parse_rules(raw_rules) do
    Enum.reduce(raw_rules, %{}, fn string, acc ->
      [name, rest] = string
      |> String.replace("}", "")
      |> String.split("{")

      rules = rest
      |> String.split(",")
      |> Enum.map(&parse_rule/1)

      Map.put(acc, name, rules)
    end)
  end

  def parse_rule(string) do
    cond do
      String.contains?(string, ">") ->
        [key_string, comp] = String.split(string, ">")
        {comp_val, <<":" <> dest>>} = Integer.parse(comp)
        key = String.to_atom(key_string)
        {key, :gt, comp_val, dest}
      String.contains?(string, "<") ->
        [key_string, comp] = String.split(string, "<")
        {comp_val, <<":" <> dest>>} = Integer.parse(comp)
        key = String.to_atom(key_string)
        {key, :lt, comp_val, dest}
      true -> {nil, :eq, nil, string}
    end
  end
end
