defmodule D6C2 do
  alias Utils.Parser

  def run(ext) do
    [time_string, distance_string] = Parser.parse("d6/#{ext}")
    distance = parse_vals(distance_string)
    time = parse_vals(time_string)

    #d = (t-x)t => t^2 - xt - d = 0
    #quadratic: (t +- sqrt(t^2 - 4x))/2
    #Distance between intersections
    #  = t/2 + sqrt(t^2 - 4x)/2 - t/2 + sqrt(t^2 - 4x)/2
    #  = sqrt(t^2 - 4x)
    :math.floor(:math.sqrt(:math.pow(time, 2) - 4 * distance))
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
