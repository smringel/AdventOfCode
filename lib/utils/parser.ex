defmodule Utils.Parser do
  @integers ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]

  def parse(ext, trim \\ true, year \\ "2023") do
    "lib/#{year}/data/#{ext}.txt"
    |> File.read!()
    |> String.split("\n", trim: trim)
  end

  def read(ext, year, trim \\ true) do
    "lib/#{year}/data/#{ext}.txt"
    |> File.read!()
    |> String.split("\n", trim: trim)
  end

  def check_int(string), do: string in @integers

  def get_int(string) do
    case Integer.parse(string) do
      {int, _extra} -> int
      _ -> nil
    end
  end
end
