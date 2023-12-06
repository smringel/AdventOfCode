defmodule D5c1 do
  alias Utils.Parser

  def run(ext) do
    Parser.parse("d5/#{ext}")
  end
end
