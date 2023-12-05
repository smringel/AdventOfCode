defmodule D1 do
  alias Utils.Parser

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
    Parser.parse("d1/#{file}")
    |> Enum.map(&supplement_num(&1))
    |> Enum.map(&filter_num(&1))
    |> Enum.map(&first_and_last(&1))
    |> Enum.reduce(fn num, acc -> num + acc end)
    |> IO.puts()
  end

  def digest_file(filepath) do
    File.read!(filepath)
    |> String.split("\n", trim: true)
  end

  def supplement_num(string) do
    letters = String.graphemes(string)

    Enum.reduce(letters, "", fn letter, acc ->
      sub_string = acc <> letter

      case Enum.find(Map.keys(@num_dict), &String.contains?(sub_string, &1)) do
        nil -> sub_string
        found_key -> acc <> Map.get(@num_dict, found_key) <> letter
      end
    end)
  end

  def filter_num(string) do
    string
    |> String.graphemes()
    |> Enum.reduce([], fn grapheme, acc ->
      case Integer.parse(grapheme) do
        {int, _} -> acc ++ [Integer.to_string(int)]
        _ -> acc
      end
    end)
  end

  def first_and_last(num_list) do
    (List.first(num_list) <> List.last(num_list))
    |> Integer.parse()
    |> elem(0)
  end
end
