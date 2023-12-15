defmodule Utils.Benchmark do
  def measure(func) do
    func
    |> :timer.tc
    |> elem(0)
    |> Kernel./(1_000_000)
  end
end
