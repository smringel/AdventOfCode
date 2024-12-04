defmodule Day1 do
  import Utils.Parser

  def run(file) do
    read("day1/#{file}", "2024")
    |> compile_lists()
    |> Enum.map(& Enum.sort(&1))
    |> add_distances()
    |> then(&IO.puts(inspect(&1)))
  end

  defp compile_lists(string_array) do
    string_array
    |> Enum.reduce([[], []], fn list_row, [list1_acc, list2_acc] ->
      values = list_row
      |> String.split("   ")
      |> Enum.map(& get_int(&1))

      [list1_acc ++ [List.first(values)], list2_acc ++ [List.last(values)]]
    end)
  end

  defp add_distances(lists) do
    Enum.zip_reduce(lists, 0, fn [el1, el2], acc ->
      dif = abs(el1 - el2)
      dif + acc
    end)
  end
end
