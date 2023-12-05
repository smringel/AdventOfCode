defmodule D3C1 do
  alias Utils.Parser

  def run(ext) do
    data = Parser.parse("d3/#{ext}")
    max_coords = get_max_coords(data)
    symbol_locs = find_symbols(data)
    numbers = find_numbers(data)
    proximal_numbers = filter_proximal_numbers(symbol_locs, numbers, max_coords)

    proximal_numbers
    |> Enum.map(&(&1[:num] |> Integer.parse() |> elem(0)))
    |> Enum.reduce(&Kernel.+/2)
  end

  def get_max_coords(data) do
    x = data |> Enum.at(0) |> String.length()
    y = length(data)
    {x, y}
  end

  def find_symbols(data) do
    Enum.map(data, fn row_data ->
      Enum.map(String.graphemes(row_data), fn column_datum ->
        case Integer.parse(column_datum) do
          :error -> column_datum != "."
          _ -> false
        end
      end)
    end)
  end

  def find_numbers(data) do
    Enum.with_index(data, fn row_data, row_index ->
      {row_index,
       Enum.with_index(String.graphemes(row_data), fn column_datum, column_index ->
         {column_index, column_datum}
       end)}
    end)
    |> build_numbers()
  end

  def build_numbers(number_matrix) do
    Enum.reduce(number_matrix, [], fn {row_index, row}, acc ->
      acc ++
        [
          Enum.reduce(row, [], fn {_column, column_val} = col, row_acc ->
            if Parser.check_int(column_val) do
              add_num(row_acc, col)
            else
              row_acc
            end
          end)
          |> Enum.map(&Map.put(&1, :row, row_index))
        ]
    end)
    |> List.flatten()
  end

  def add_num([], {column, column_val}) do
    [%{start: column, end: column, num: column_val}]
  end

  def add_num(row_acc, {column, column_val}) do
    Enum.find(row_acc, fn number ->
      column - number[:end] <= 1
    end)
    |> case do
      nil -> row_acc ++ [%{start: column, end: column, num: column_val}]
      num -> update_num(row_acc, num, column, column_val)
    end
  end

  def update_num(row_acc, num, column, column_val) do
    new_num = Map.merge(num, %{num: num[:num] <> column_val, end: column})
    index = Enum.find_index(row_acc, &(&1 == num))
    List.replace_at(row_acc, index, new_num)
  end

  def filter_proximal_numbers(symbols, numbers, max_coords) do
    Enum.filter(numbers, fn number ->
      adjacency_list = build_adjacency_list(number, max_coords)

      Enum.any?(adjacency_list, fn {x, y} ->
        symbols
        |> Enum.at(y)
        |> Enum.at(x)
      end)
    end)
  end

  def build_adjacency_list(number, {max_x, max_y}) do
    Enum.reduce((number[:start] - 1)..(number[:end] + 1), [], fn x, acc ->
      if x > 0 and x < max_x do
        (acc ++ [{x, number[:row]}])
        |> then(
          &if number[:row] - 1 > 0 do
            &1 ++ [{x, number[:row] - 1}]
          else
            &1
          end
        )
        |> then(
          &if number[:row] + 1 < max_y do
            &1 ++ [{x, number[:row] + 1}]
          else
            &1
          end
        )
      else
        acc
      end
    end)
  end
end
