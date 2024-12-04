defmodule D18C2 do
  alias Utils.Parser

  @dir %{"0" => :r, "1" => :d, "2" => :l, "3" => :u}
  def run(ext) do
    data =
      Parser.parse("d18/#{ext}")
      |> Enum.map(&String.split(&1, " "))
      |> Enum.map(fn
        [_dir, _num, <<"(#", hex::binary-size(5), dir::binary-size(1), ")">>] ->
          {
            @dir[dir],
            String.to_integer(hex, 16)
          }
      end)

    {corners, perimeter} = dig(data, {0, 0}, [], 0)

    interior_area = shoelace(corners)
    picks(interior_area, perimeter)
  end

  def dig([], _pos, corners, perimeter), do: {corners, perimeter}

  def dig([{dir, dist} | rest], pos, corners, perimeter) do
    travel = Function.capture(__MODULE__, dir, 2)
    next = travel.(dist, pos)
    dig(rest, next, corners ++ [next], perimeter + dist)
  end

  def shoelace(visited) do
    visited
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.reduce(0, fn [{i1, j1}, {i2, j2}], acc ->
      acc + (i1 - i2) * (j1 + j2)
    end)
    |> div(2)
    |> abs()
  end

  def picks(i, b), do: round(i + b / 2 + 1)

  def r(dx, {x, y}), do: {x + dx, y}
  def l(dx, {x, y}), do: {x - dx, y}
  def u(dy, {x, y}), do: {x, y - dy}
  def d(dy, {x, y}), do: {x, y + dy}
end
