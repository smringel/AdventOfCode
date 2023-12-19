defmodule D18C1 do
  alias Utils.Parser

  def run(ext) do
    Parser.parse("d18/#{ext}")
  end
end
