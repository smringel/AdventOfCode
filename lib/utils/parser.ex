defmodule Utils.Parser do
  @integers ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]

  def parse(ext, trim \\ true) do
    "lib/data/#{ext}.txt"
    |> File.read!()
    |> String.split("\n", trim: trim)
  end

  def check_int(string), do: string in @integers

  def get_int(string), do: Integer.parse(string) |> elem(0)
end
