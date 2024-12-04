defmodule D15C2 do
  alias Utils.Parser

  def run(ext) do
    Parser.parse("d15/#{ext}")
    |> List.first()
    |> String.split(",")
    |> get_box_values()
    |> sort_lenses()
    |> Enum.reduce(0, fn {box, lenses}, acc ->
      (box + 1) * calculate_power(lenses) + acc
    end)
  end

  def calculate_power(lenses) do
    Enum.reduce(lenses, 0, fn {_label, {focal_length, slot}}, acc ->
      focal_length * slot + acc
    end)
  end

  def get_box_values(data) do
    Enum.map(data, fn string ->
      [val, lens] =
        if String.contains?(string, "-") do
          String.split(string, "-")
        else
          String.split(string, "=")
        end

      {String.to_atom(val), Parser.get_int(lens)}
    end)
  end

  def sort_lenses(box_values) do
    Enum.reduce(box_values, %{}, fn {label, lens}, acc ->
      hash = hash(label)
      box = Map.get(acc, hash, Keyword.new())

      if is_nil(lens) do
        remove_lens(box, label)
      else
        update_lens(box, label, lens)
      end
      |> then(&Map.put(acc, hash, &1))
    end)
    |> Enum.reject(fn {_key, val} -> val == [] end)
  end

  def remove_lens(box, label) do
    {_prev_lens, prev_slot} = Keyword.get(box, label, {nil, nil})

    if is_nil(prev_slot) do
      box
    else
      Enum.map(box, fn {label, {lens, slot}} ->
        if slot > prev_slot do
          {label, {lens, slot - 1}}
        else
          {label, {lens, slot}}
        end
      end)
    end
    |> Keyword.delete(label)
  end

  def update_lens(box, label, lens) do
    {_prev_lens, slot} = Keyword.get(box, label, {nil, length(box) + 1})
    Keyword.put(box, label, {lens, slot})
  end

  def hash(atom) do
    atom
    |> Atom.to_string()
    |> String.to_charlist()
    |> Enum.reduce(0, fn ascii, acc ->
      ascii
      |> Kernel.+(acc)
      |> Kernel.*(17)
      |> rem(256)
    end)
  end
end
