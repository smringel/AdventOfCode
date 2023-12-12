defmodule D11C2 do
  alias Utils.Parser

  @mod 999_999

  def run(ext) do
    data = Parser.parse("d11/#{ext}")
    |> Enum.map(&String.graphemes/1)

    rows = find_empty_rows(data)
    cols = find_empty_cols(data)

    data
    |> find_galaxies()
    |> calc_distances(rows, cols, 0)
  end

  def find_empty_rows(data) do
    Enum.reduce(0..length(data) - 1, [], fn y, acc ->
      data
      |> Enum.at(y)
      |> Enum.any?(& &1 == "#")
      |> if do
        acc
      else
        acc ++ [y]
      end
    end)
  end

  def find_empty_cols(data) do
    Enum.reduce(0..length(data) - 1, [], fn x, acc ->
      if Enum.any?(data, &Enum.at(&1, x) == "#") do
        acc
      else
        acc ++ [x]
      end
    end)
  end

  def find_galaxies(map) do
    Enum.reduce(0..length(map) - 1, [], fn y, acc ->
      map
      |> Enum.at(y)
      |> Enum.with_index()
      |> Enum.filter(fn {val, _x} -> val == "#" end)
      |> Enum.map(fn {_val, x} -> {x, y} end)
      |> then(& acc ++ &1)
    end)
  end

  def calc_distances([], _empty_rows, _empty_cols, sum), do: sum
  def calc_distances([galaxy | galaxies], empty_rows, empty_cols, sum) do
    Enum.map(galaxies, fn {x, y} ->
      gal_x = elem(galaxy, 0)
      gal_y = elem(galaxy, 1)
      x_mod = empty_mod(x, gal_x, empty_cols)
      y_mod = empty_mod(y, gal_y, empty_rows)
      abs(x - gal_x) + abs(y - gal_y) + x_mod + y_mod
    end)
    |> Enum.sum()
    |> then(&calc_distances(galaxies, empty_rows, empty_cols, sum + &1))
  end

  def empty_mod(a, b, empties) do
    Enum.reduce(empties, 0, fn empty, acc ->
      cond do
        a < empty and empty < b -> acc + 1
        a > empty and empty > b -> acc + 1
        true -> acc
      end
    end)
    |> Kernel.*(@mod)
  end
end
