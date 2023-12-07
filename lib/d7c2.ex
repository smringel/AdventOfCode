defmodule D7C2 do
  alias Utils.Parser

  @hand_strength [:card, :pair, :two_pair, :three_of_kind, :full, :four_of_kind, :five_of_kind]
  @card_strength ["J", "2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K", "A"]

  def run(ext) do
    Parser.parse("d7/#{ext}")
    |> Enum.reduce([], fn string, acc ->
      [hand, bid_string] = String.split(string, " ")
      acc ++ [{hand, Parser.get_int(bid_string)}]
    end)
    |> Enum.map(fn {card, bet} ->
      score = card
      |> group()
      |> score()
      {card, bet, score}
    end)
    |> Enum.sort(&stronger_hand?/2)
    |> Enum.reverse()
    |> Enum.with_index(fn {_, bet, _}, index -> {bet, index + 1} end)
    |> Enum.reduce(0, fn {bet, rank}, acc ->
      acc + (bet * rank)
    end)
  end

  def stronger_hand?({xhand, _, x}, {yhand, _, y}) do
    x_strength = Enum.find_index(@hand_strength, & &1 == x)
    y_strength = Enum.find_index(@hand_strength, & &1 == y)
    cond do
      x_strength > y_strength -> true
      x_strength < y_strength -> false
      true -> compare_hands(xhand, yhand)
    end
  end

  def compare_hands(x, y) do
    x_cards = String.graphemes(x)
    y_cards = String.graphemes(y)
    compare_cards(x_cards, y_cards)
  end

  def compare_cards([x], [y]), do: stronger_card?(x, y)
  def compare_cards([x | x_tl], [y | y_tl]) do
    case stronger_card?(x, y) do
      :eq -> compare_cards(x_tl, y_tl)
      bool -> bool
    end
  end

  def stronger_card?(x, y) do
    x_strength = Enum.find_index(@card_strength, & &1 == x)
    y_strength = Enum.find_index(@card_strength, & &1 == y)
    cond do
      x_strength > y_strength -> true
      x_strength < y_strength -> false
      true -> :eq
    end
  end

  def group(cards) do
    cards
    |> String.graphemes()
    |> Enum.group_by(& &1)
    |> Map.values()
    |> Enum.sort_by(&length(&1), :desc)
  end

  def score([[_, _, _, _, _]]), do: :five_of_kind
  def score([[_, _, _, _], [_]]), do: :four_of_kind
  def score([[_, _, _], [_, _]]), do: :full
  def score([[_, _, _], [_], [_]]), do: :three_of_kind
  def score([[_, _], [_, _] | _]), do: :two_pair
  def score([[_, _] | _]), do: :pair
  def score(_), do: :card
end
