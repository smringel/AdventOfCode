defmodule Utils.Parser do
  def parse(ext) do
    "lib/data/#{ext}.txt"
    |> File.read!()
    |> String.split("\n", trim: true)
  end
end
