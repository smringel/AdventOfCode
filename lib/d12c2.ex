defmodule D12C2 do
  alias Utils.Parser

  def run(ext) do
    Parser.parse("d12/#{ext}")
    |> Task.async_stream(fn row ->
      [seq_string, record] = String.split(row, " ", trim: true, parts: 2)

      sequence =
        seq_string
        |> String.graphemes()
        |> Enum.chunk_by(& &1)
        |> Enum.map(fn chunk ->
          if Enum.any?(chunk, &(&1 == "?")), do: chunk, else: Enum.join(chunk)
        end)
        |> List.flatten()
        |> Kernel.++(["?"])
        |> List.duplicate(5)
        |> List.flatten()
        |> Enum.drop(-1)

      counts =
        record
        |> String.split(",")
        |> Enum.map(&Parser.get_int/1)
        |> List.duplicate(5)
        |> List.flatten()

        combinations(sequence, counts, 1)
      end)
      |> Enum.reduce(0, fn {:ok, total}, acc -> acc + total end)
  end

  defp combinations(sequence, counts, acc, inside? \\ false)

  defp combinations([sequence_head | sequence_tail] = sequence, [count_head | count_tail] = counts, acc, inside?) do
    case Process.get({sequence, counts}) do
      nil ->
        if length(sequence) < length(counts) do
          memoize({sequence, counts}, 0)
        else
          cond do
            String.contains?(sequence_head, ".") ->
              if inside? do
                memoize({sequence, counts}, 0)
              else
                memoize(
                  {sequence, counts},
                  acc * combinations(sequence_tail, counts, acc, false)
                )
              end

            String.contains?(sequence_head, "#") ->
              cond do
                count_head < String.length(sequence_head) ->
                  memoize({sequence, counts}, 0)

                count_head == String.length(sequence_head) and length(sequence_tail) > 0 ->
                  memoize({sequence, counts}, acc * combinations(tl(sequence_tail), count_tail, acc))
                count_head == String.length(sequence_head) -> memoize({sequence, counts}, acc)

                count_head > String.length(sequence_head) and length(sequence_tail) > 0 ->
                  total = combinations(
                    sequence_tail,
                    [count_head - String.length(sequence_head) | count_tail],
                    acc,
                    true
                  )
                  memoize({sequence, counts}, total)

                count_head > String.length(sequence_head) ->
                  memoize({sequence, counts}, 0)
              end

            sequence_head == "?" ->
              count_if_spring =
                if length(sequence_tail) > 0 do
                  [next_chunk | rest] = sequence_tail

                  cond do
                    String.contains?(next_chunk, ".") and count_head > 1 -> 0

                    String.contains?(next_chunk, "#") and count_head == 1 -> 0

                    String.contains?(next_chunk, "?") and count_head == 1 ->
                      combinations(rest, count_tail, acc, false)

                    count_head == 1 ->
                      if length(sequence_tail) > 0 do
                        combinations(rest, count_tail, acc, false)
                      else
                        acc
                      end

                    true ->
                      combinations(sequence_tail, [count_head - 1 | count_tail], acc, true)
                  end
                else
                  if count_head == 1 do
                    1
                  else
                    0
                  end
                end

              count_if_skipped =
                if inside? do
                  0
                else
                  combinations(sequence_tail, counts, acc, inside?)
                end

              memoize({sequence, counts}, acc * (count_if_skipped + count_if_spring))
          end
        end

      result ->
        result
    end
  end

  defp combinations([], [], _acc, _inside?), do: 1
  defp combinations([], _counts, _acc, _inside?), do: 0

  defp combinations(sequence, [], _acc, _inside?) do
    if Enum.any?(sequence, &String.contains?(&1, "#")) do
      0
    else
      1
    end
  end

  defp memoize({sequence, counts}, total) do
    Process.put({sequence, counts}, total)
    total
  end
end
