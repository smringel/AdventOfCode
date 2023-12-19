defmodule D16C2 do
  alias Utils.Parser

  @hor_dirs [:e, :w]
  @vert_dirs [:n, :s]

  def run(ext) do
    map =
      Parser.parse("d16/#{ext}")
      |> Enum.map(&String.graphemes/1)

    horizontal_entries =
      Enum.reduce(0..(length(map) - 1), [], fn y, acc ->
        x_max = length(hd(map))
        acc ++ [{{-1, y}, :e, []}, {{x_max, y}, :w, []}]
      end)

    vertical_entries =
      Enum.reduce(0..(length(hd(map)) - 1), [], fn x, acc ->
        y_max = length(map)
        acc ++ [{{x, -1}, :s, []}, {{x, y_max}, :n, []}]
      end)

    Task.async_stream(horizontal_entries ++ vertical_entries, fn entry ->
      entry
      |> trace(map)
      |> Enum.uniq_by(fn {x, y, _dir} -> {x, y} end)
      |> Enum.count()
    end)
    |> Enum.reduce([], fn {:ok, count}, acc -> acc ++ [count] end)
    |> Enum.max()
  end

  def trace({pos, dir, acc}, map) do
    case next_pos(map, pos, dir) do
      nil ->
        acc

      {x, y} = next_pos ->
        if {x, y, dir} in acc do
          acc
        else
          updated_acc = acc ++ [{x, y, dir}]

          map
          |> Enum.at(y)
          |> Enum.at(x)
          |> case do
            "." ->
              trace({next_pos, dir, updated_acc}, map)

            "-" ->
              if dir in @hor_dirs do
                trace({next_pos, dir, updated_acc}, map)
              else
                trace({next_pos, :e, updated_acc}, map)
                |> then(&trace({next_pos, :w, &1}, map))
              end

            "|" ->
              if dir in @vert_dirs do
                trace({next_pos, dir, updated_acc}, map)
              else
                # IO.inspect("here")
                trace({next_pos, :n, updated_acc}, map)
                |> then(&trace({next_pos, :s, &1}, map))
              end

            "/" ->
              case dir do
                :n -> trace({next_pos, :e, updated_acc}, map)
                :s -> trace({next_pos, :w, updated_acc}, map)
                :e -> trace({next_pos, :n, updated_acc}, map)
                :w -> trace({next_pos, :s, updated_acc}, map)
              end

            # \
            _ ->
              case dir do
                :n -> trace({next_pos, :w, updated_acc}, map)
                :s -> trace({next_pos, :e, updated_acc}, map)
                :e -> trace({next_pos, :s, updated_acc}, map)
                :w -> trace({next_pos, :n, updated_acc}, map)
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
