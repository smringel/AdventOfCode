defmodule D15C1 do
  alias Utils.Parser

  def run(ext) do
    Parser.parse("d15/#{ext}")
    |> List.first()
    |> String.split(",")
    |> Enum.reduce(0, & &2 + hash(&1))
  end

  def hash(string) do
    string
    |> String.to_charlist()
    |> Enum.reduce(0, fn ascii, acc ->
      ascii
      |> Kernel.+(acc)
      |> Kernel.*(17)
      |> rem(256)
    end)
  end
end
