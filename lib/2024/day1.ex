defmodule Day1 do
  import Utils.Parser

  @num_dict %{
    "one" => "1",
    "two" => "2",
    "three" => "3",
    "four" => "4",
    "five" => "5",
    "six" => "6",
    "seven" => "7",
    "eight" => "8",
    "nine" => "9",
    "zero" => "0"
  }

  def run(file) do
    parse("d1/day1/#{file}")
    |> IO.puts()
  end
end
