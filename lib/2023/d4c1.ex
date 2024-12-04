defmodule D4C1 do
  alias Utils.Parser

  def run(ext) do
    Parser.parse("d4/#{ext}")
    |> parse_cards()
    |> Enum.map(&convert_to_numbers/1)
    |> Enum.map(&point_cards/1)
    |> Enum.reduce(&Kernel.+/2)
  end

  def parse_cards(data) do
    Enum.map(data, fn card ->
      card
      |> String.split(":", trim: true)
      |> then(fn [_hd | tl] -> tl end)
      |> Enum.map(&String.split(&1, "|", trim: true))
      |> List.flatten()
    end)
  end

  def convert_to_numbers(strings) do
    Enum.map(strings, fn string ->
      string
      |> String.split(" ")
      |> Enum.reject(&(&1 == ""))
      |> Enum.map(fn int ->
        Integer.parse(int)
        |> elem(0)
      end)
    end)
  end

  def point_cards([winning, nums]) do
    Enum.count(nums, &(&1 in winning))
    |> then(&:math.pow(2, &1 - 1))
    |> Kernel.trunc()
  end
end
