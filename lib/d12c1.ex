defmodule D12C1 do
  alias Utils.Parser

  def run(ext) do
    Parser.parse("d12/#{ext}")
    |> Enum.map(&String.split(&1, " "))
    |> Enum.map(fn [row, record] ->
      numeric_record =
        record
        |> String.split(",")
        |> Enum.map(&Parser.get_int/1)

      {row, numeric_record}
    end)
    |> Enum.map(&combinations/1)
    |> Enum.sum()
  end

  def combinations({row_string, record}) do
    row = String.graphemes(row_string)
    springs_count = Enum.sum(record)
    unk_count = Enum.count(row, &(&1 == "?"))
    known_count = Enum.count(row, &(&1 == "#"))

    cond do
      length(row) == springs_count + length(record) - 1 ->
        1

      unk_count == 0 ->
        1

      springs_count == 0 ->
        1

      true ->
        Enum.with_index(row, fn elem, index -> {index, elem} end)
        |> Enum.filter(fn {_index, val} -> val == "?" end)
        |> Enum.map(fn {index, _val} -> index end)
        |> Combination.combine(springs_count - known_count)
        |> Enum.map(fn unk_locs ->
          Enum.reduce(unk_locs, row, &List.replace_at(&2, &1, "#"))
          |> then(
            &Enum.map(&1, fn
              "?" -> "."
              val -> val
            end)
          )
          |> Enum.chunk_by(& &1)
          |> Enum.filter(&(hd(&1) == "#"))
          |> Enum.map(&length/1)
        end)
        |> Enum.count(&(&1 == record))
    end
  end
end
