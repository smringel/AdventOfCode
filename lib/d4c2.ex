defmodule D4C2 do
  alias Utils.Parser

  def run(ext) do
    cards = Parser.parse("d4/#{ext}")
    |> parse_cards()
    |> Enum.map(&convert_to_numbers/1)

    initial_cards = Enum.reduce(1..length(cards), %{}, fn x, acc ->
      card = Integer.to_string(x)
      Map.put(acc, card, 1)
    end)

    Enum.reduce(cards, %{cur: 1, cards: initial_cards}, fn card, acc ->
      matches = point_card(card)
      num_cur = acc[:cur]
      |> Integer.to_string()
      |> then(&Map.get(acc[:cards], &1))

      if matches > 0 do
      updated_cards =
        Enum.reduce(1..matches, acc[:cards], fn x, new_acc ->
          card_to_copy = Integer.to_string(x + acc[:cur])
          Map.put(new_acc, card_to_copy, new_acc[card_to_copy] + num_cur)
        end)

      %{cur: acc[:cur] + 1, cards: updated_cards}
      else
        %{acc | cur: acc[:cur] + 1}
      end
    end)
    |> Map.get(:cards)
    |> Map.values()
    |> Enum.sum()
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

  def point_card([winning, nums]) do
    Enum.count(nums, & &1 in winning)
  end
end
