defmodule D4C1 do
  alias Utils.Parser

  def run(ext) do
    Parser.parse("d4/#{ext}")
  end
end
