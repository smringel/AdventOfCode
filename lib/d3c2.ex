defmodule D3C2 do
  alias Utils.Parser

  def run(ext) do
    data = Parser.parse("d3/#{ext}")
    max_coords = get_max_coords(data)
    gear_matrix = find_gears(data)
    numbers = find_numbers(data)

    filter_proximal_numbers(gear_matrix, numbers, max_coords)
    |> Enum.map(fn nums -> Enum.reduce(nums, &Kernel.*/2) end)
    |> Enum.reduce(&Kernel.+/2)
  end

  def get_max_coords(data) do
    x = data |> Enum.at(0) |> String.length()
    y = length(data)
    {x, y}
  end

  def find_gears(data) do
    Enum.map(data, fn row_data ->
      Enum.map(String.graphemes(row_data), &(&1 == "*"))
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

  @spec filter_proximal_numbers(any, any, any) :: list
  def filter_proximal_numbers(gear_matrix, numbers, max_coords) do
    adjacency_lists =
      Enum.map(numbers, fn number ->
        {number[:num], build_adjacency_list(number, max_coords)}
      end)

    gear_locations = get_gear_locations(gear_matrix)

    Enum.reduce(gear_locations, [], fn gear, acc ->
      proximal_numbers =
        Enum.filter(adjacency_lists, fn {_number, adj} ->
          gear in adj
        end)
        |> Enum.map(fn {num, _adj} ->
          num |> Integer.parse() |> elem(0)
        end)

      if Enum.count(proximal_numbers) == 2 do
        acc ++ [proximal_numbers]
      else
        acc
      end
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

  def get_gear_locations(gear_matrix) do
    Enum.with_index(gear_matrix, fn row, row_index ->
      Enum.with_index(row, fn col, col_index ->
        {row_index, col_index, col}
      end)
    end)
    |> List.flatten()
    |> Enum.filter(fn {_row, _col, val} -> val == true end)
    |> Enum.map(fn {y, x, _} -> {x, y} end)
  end
end
