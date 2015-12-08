defmodule Spex.Structure do
  alias Spex.Structure.Spec
  alias Spex.Structure.Spec.Describe

  defmacro __using__(_opts) do
    quote do
      alias Spex.Structure.Spec
      alias Spex.Structure.Spec.Describe

      import Spex.Structure
    end
  end

  defmodule Spec do
    defstruct children: %{}

    defmodule Describe do
      defstruct lets: %{}, before_alls: %{}, before_eachs: %{}, its: %{}, children: %{}
    end
  end

  def add_describe(node, [new_level]) do
    %{node | children: Map.put(node.children, new_level, %Describe{})}
  end
  def add_describe(node, [head|tail]) do
    case node.children[head] do
      nil -> raise "no child with level #{head} found in #{inspect node}.  Levels: #{inspect [head|tail]}"
      %Describe{} = child ->
        %{node | children: Map.put(node.children, head, add_describe(child, tail))}
    end
  end
end
