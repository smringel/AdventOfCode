defmodule Broadcast do
  defstruct [:id, :outputs]
end

defmodule FF do
  defstruct [:id, :outputs, state: :off]
end

defmodule Con do
  defstruct [:id, :inputs, :outputs]
end

defmodule D20C1 do
  alias Utils.Parser

  @doc """
  flip-flop (%):
    Low pulse flips on/off. If flips on, sends High pulse, else low pulse
    High pulse does nothing
    initially off
  conjunction (&):
    Remembers last pulse from each input
    Updates memory on receipt of pulse
    Sends low if it remembers all high inputs, else high
    initially low
  broadcast:
    sends received pulse to all outputs (entry point)

  Signals must be handled at each level before moving deeper
  """
  def run(ext) do
    modules = Parser.parse("d20/#{ext}")
    |> Enum.map(&String.split(&1, " -> "))
    |> Enum.map(&setup_module/1)
    |> assign_inputs()

    {%{high: highs, low: lows} = res, cycle_start, cycle} = broadcast(modules, modules, true)
    MapSet.size(cycle)
    IO.inspect(res, label: "res")
    # cycle

    # x1 = Enum.find_index(cycle, & &1 == dup)
    # cycle_length = length(cycle) - x1 + 1
    # length(cycle)
  end

  def broadcast(modules, init, states \\ MapSet.new(), counts \\ %{low: 0, high: 0}, entry?) do
    {_, broadcast} = Enum.find(modules, &match?(%Broadcast{}, elem(&1, 1)))

    updated_counts = %{low: counts[:low] + 1 + length(broadcast.outputs), high: counts[:high]}
    curs = [{broadcast, :low}]

    {pulse_map, updated_states, stop_method} = signal_outputs(curs, modules, updated_counts, {init, MapSet.put(states, modules)}, entry?)
    case stop_method do
      :term -> {pulse_map, 0, updated_states}
      :cycle -> broadcast(modules, init, updated_states, pulse_map, false)
    end
  end

  def signal_outputs(curs, modules, counts, {init, states}, entry?) do
    IO.inspect(counts, label: "counts")
      updated =
      Enum.reduce(curs, [], fn {cur, pulse}, acc ->
        s =
          Enum.reduce(cur.outputs, [], fn out, update_acc ->
            update_acc ++ [signal(modules[out], pulse, cur.id)]
          end)

        acc ++ [s]
      end)
      |> List.flatten()

      next = Enum.reject(updated, fn {_module, pulse} -> is_nil(pulse) end) |> IO.inspect(label: "")
      updated_state = Enum.reduce(updated, modules, fn
        {nil, _}, acc -> acc
        {update, _}, acc -> Map.put(acc, update.id, update)
      end)

      updated_count = update_counts(counts, next)
      cond do
        # Need a way to compare the modules to init without exiting on first try
        Map.equal?(modules, init) and not entry? -> {updated_count, states, :term}
        MapSet.member?(states, updated_state) or next == [] -> {updated_count, states, :cycle}
        true -> signal_outputs(next, updated_state, updated_count, {init, MapSet.put(states, updated_state)}, false)
      end
  end

  def signal(%FF{} = module, :high, _), do: {module, nil}
  def signal(%FF{} = module, :low, _) do
    case module.state do
      :off -> {Map.put(module, :state, :on), :high}
      :on -> {Map.put(module, :state, :off), :low}
    end
  end

  def signal(%Con{} = module, pulse, src) do
    updated_inputs = Map.put(module.inputs, src, pulse)

    if Enum.all?(updated_inputs, fn {_id, pulse} -> pulse == :high end) do
      {Map.put(module, :inputs, updated_inputs), :low}
    else
      {Map.put(module, :inputs, updated_inputs), :high}
    end
  end

  def signal(nil, _, _), do: {nil, nil}

  def update_counts(counts, next) do
    lows = Enum.count(next, fn {_, pulse} -> pulse == :low end)
    highs = Enum.count(next, fn {_, pulse} -> pulse == :high end)
    counts
    |> Map.put(:low, counts[:low] + lows)
    |> Map.put(:high, counts[:high] + highs)
  end

  def setup_module([<<type::binary-size(1), id_string::binary>>, output_string]) do
    outputs =
      output_string
      |> String.split(", ")
      |> Enum.map(&String.to_atom/1)

    id = String.to_atom(id_string)

    case type do
      "b" -> {:broadcast, %Broadcast{outputs: outputs}}
      "%" -> {id, %FF{id: id, outputs: outputs}}
      "&" -> {id, %Con{id: id, outputs: outputs}}
    end
  end

  def assign_inputs(modules) do
    Enum.map(modules, fn
      {id, %Con{} = module} ->
        modules
        |> Enum.filter(&(id in elem(&1, 1).outputs))
        |> Enum.reduce([], &(&2 ++ [{elem(&1, 0), :low}]))
        |> then(&{id, Map.put(module, :inputs, Enum.into(&1, %{}))})

      module ->
        module
    end)
    |> Enum.into(%{})
  end
end
