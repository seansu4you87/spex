defmodule Spex.Macros.Agent do
  def start_link do
    initial_state = %{
      stacks: %{},
      structures: %{}
    }
    Agent.start_link(fn -> initial_state end, name: __MODULE__)
  end

  def get_stack(mod) do
    Agent.get(__MODULE__, fn(state) ->
      state.stacks[mod]
    end)
  end

  def push_stack(mod, message) do
    Agent.get_and_update(__MODULE__, fn(state) ->
      stacks = state.stacks
      if stacks[mod] == nil, do: stacks = Map.put(stacks, mod, [])

      stack = stacks[mod]
      stack = [message] ++ stack

      stacks = Map.put(stacks, mod, stack)
      {stack, Map.put(state, :stacks, stacks)}
    end)
  end

  def pop_stack(mod) do
    Agent.get_and_update(__MODULE__, fn(state) ->
      stacks = state.stacks
      stack = stacks[mod]
      case stack do
        nil -> {nil, state}
        [] -> {nil, state}
        [head|tail] ->
          stacks = Map.put(stacks, mod, tail)
          {head, Map.put(state, :stacks, stacks)}
      end
    end)
  end

  def get_structure(mod) do
    Agent.get(__MODULE__, fn(state) ->
      state.structures[mod]
    end)
  end

  def put_structure(mod, structure) do
    Agent.get_and_update(__MODULE__, fn(state) ->
      structures = state.structures
      structures = Map.put(structures, mod, structure)
      {structure, Map.put(state, :structures, structures)}
    end)
  end
end
