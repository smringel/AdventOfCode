defmodule D6C2 do
  alias Utils.Parser

  def run(ext) do
    [time_string, distance_string] = Parser.parse("d6/#{ext}")
    distance = parse_vals(distance_string) |> IO.inspect(label: "a")
    time = parse_vals(time_string) |> IO.inspect(label: "b")

    min_charge_time = distance / time |> :math.floor()
    failing_runs = round(min_charge_time * 2 + 1)
    time - failing_runs
  end

  def parse_vals(string) do
    string
    |> String.split(":")
    |> List.last()
    |> String.split(" ", trim: true)
    |> Enum.join()
    |> Parser.get_int()
  end
end
