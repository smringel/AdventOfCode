defmodule D16C1 do
  alias Utils.Parser

  @hor_dirs [:e, :w]
  @vert_dirs [:n, :s]

  def run(ext) do
    map =
    Parser.parse("d16/#{ext}")
    |> Enum.map(&String.graphemes/1)

    visited =
    map
    |> trace({0, 0}, :e, [{0, 0, :e}])
    |> Enum.map(fn {x, y, _dir} -> {x, y} end)
    |> Enum.uniq()

    Enum.reduce(0..length(map) - 1, [], fn y, acc ->
      acc ++ [Enum.reduce(0..length(hd(map)) - 1, [], fn x, x_acc ->
        if {x, y} in visited do
          x_acc ++ ["#"]
        else
          x_acc ++ ["."]
        end
      end)]
    end)
    |> IO.inspect()

    Enum.count(visited)
  end

  def trace(map, pos, dir, acc) do
    case next_pos(map, pos, dir) do
      nil ->
        acc

      {x, y}  = next_pos ->
        if {x, y, dir} in acc do
          acc
        else
          updated_acc = acc ++ [{x, y, dir}]

          map
          |> Enum.at(y)
          |> Enum.at(x)
          |> case do
            "." ->
              trace(map, next_pos, dir, updated_acc)

            "-" ->
              if dir in @hor_dirs do
                trace(map, next_pos, dir, updated_acc)
              else
                trace(map, next_pos, :e, updated_acc)
                |> then(&trace(map, next_pos, :w, &1))
              end

            "|" ->
              if dir in @vert_dirs do
                trace(map, next_pos, dir, updated_acc)
              else
                # IO.inspect("here")
                trace(map, next_pos, :n, updated_acc)
                |> then(&trace(map, next_pos, :s, &1))
              end

            "/" -> case dir do
              :n -> trace(map, next_pos, :e, updated_acc)
              :s -> trace(map, next_pos, :w, updated_acc)
              :e -> trace(map, next_pos, :n, updated_acc)
              :w -> trace(map, next_pos, :s, updated_acc)
            end

            # \
            _ -> case dir do
              :n -> trace(map, next_pos, :w, updated_acc)
              :s -> trace(map, next_pos, :e, updated_acc)
              :e -> trace(map, next_pos, :s, updated_acc)
              :w -> trace(map, next_pos, :n, updated_acc)
            end
          end
        end
    end
  end

  def next_pos(map, {x, y}, :e), do: if(x + 1 < length(hd(map)), do: {x + 1, y}, else: nil)
  def next_pos(_map, {x, y}, :w), do: if(x - 1 >= 0, do: {x - 1, y}, else: nil)
  def next_pos(_map, {x, y}, :n), do: if(y - 1 >= 0, do: {x, y - 1}, else: nil)
  def next_pos(map, {x, y}, :s), do: if(y + 1 < length(map), do: {x, y + 1}, else: nil)
end
