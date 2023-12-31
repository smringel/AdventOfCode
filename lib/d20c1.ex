defmodule D20C1 do
  alias Utils.Parser

  def run(ext) do
    data = Parser.parse("d19/#{ext}")
    parts_start = Enum.find_index(data, &String.contains?(&1, "{x="))
    {raw_rules, raw_parts} = Enum.split(data, parts_start)

    parts = parse_parts(raw_parts)
    rules = parse_rules(raw_rules)

    Enum.map(parts, &run_rules(&1, rules, Map.get(rules, "in")))
    |> Enum.map(fn
      {map, :accept} -> map |> Map.values() |> Enum.sum()
      _ -> 0
    end)
    |> Enum.sum()
  end

  def run_rules(part, rules, rule_set) do
    [{test, dest} | rest] = rule_set

    if test.(part) do
      case dest do
        "A" -> {part, :accept}
        "R" -> {part, :reject}
        _ -> run_rules(part, rules, Map.get(rules, dest))
      end
    else
      run_rules(part, rules, rest)
    end
  end

  def parse_parts(list) do
    Enum.map(list, fn string ->
      string
      |> String.replace("{", "")
      |> String.split(",")
      |> Enum.map(fn val ->
        val
        |> String.split_at(2)
        |> elem(1)
        |> Parser.get_int()
      end)
      |> then(fn [x, m, a, s] -> %{x: x, m: m, a: a, s: s} end)
    end)
  end

  def parse_rules(raw_rules) do
    Enum.reduce(raw_rules, %{}, fn string, acc ->
      [name, rest] =
        string
        |> String.replace("}", "")
        |> String.split("{")

      rules =
        rest
        |> String.split(",")
        |> Enum.map(&parse_rule/1)

      Map.put(acc, name, rules)
    end)
  end

  def parse_rule(<<key_string::binary-size(1), comparator::binary-size(1), rest::binary>>)
      when comparator in [">", "<"] do
    {comp_val, <<":" <> dest>>} = Integer.parse(rest)
    key = String.to_atom(key_string)
    base_func = Function.capture(Kernel, String.to_atom(comparator), 2)
    func = &base_func.(Map.get(&1, key), comp_val)
    {func, dest}
  end

  def parse_rule(string), do: {fn _ -> true end, string}
end
