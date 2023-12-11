defmodule D11C1 do
  alias Utils.Parser

  def run(ext) do
    data = Parser.parse("d11/#{ext}")

    data
    |> expand_rows()
    |> Enum.map(&String.graphemes/1)
    |> expand_cols()
    |> find_galaxies()
    |> calc_distances()
  end

  def expand_rows(data) do
    Enum.reduce(data, [], fn row, acc ->
      if String.contains?(row, "#") do
        acc ++ [row]
      else
        acc ++ [row, row]
      end
    end)
  end

  def expand_cols(data) do
    empty_cols = Enum.reduce(0..length(data) - 1, [], fn x, acc ->
      if Enum.all?(data, &Enum.at(&1, x) == ".") do
        acc ++ [x]
      else
        acc
      end
    end)
    |> Enum.reverse()

    Enum.reduce(data, [], fn row, acc ->
      acc ++ [Enum.reduce(empty_cols, row, fn col, row_acc ->
        List.insert_at(row_acc, col, ".")
      end)]
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

  def calc_distances(galaxies) do
    galaxies
    |> Enum.reduce(0, fn galaxy, acc ->
      Enum.map(galaxies, fn {x, y} -> abs(x - elem(galaxy, 0)) + abs(y - elem(galaxy, 1)) end)
      |> Enum.sum()
      |> Kernel.+(acc)
    end)
    |> Kernel./(2)
    |> round()
  end
end
