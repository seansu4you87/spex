defmodule Spex.Structure do
  alias Spex.Structure.Spec
  alias Spex.Structure.Spec.Describe
  alias Spex.Structure.Spec.Let

  defmacro __using__(_opts) do
    quote do
      import Spex.Structure, only: [add_describe: 2, add_let: 4, get_lets: 2]
    end
  end

  defmodule Spec do
    defstruct children: %{}

    defmodule Describe do
      defstruct lets: %{}, before_alls: %{}, before_eachs: %{}, its: %{}, children: %{}
    end

    defmodule Let do
      defstruct name: :"", body: {}
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

  def add_let(%Describe{} = node, [], name, body) do
    %{node | lets: Map.put(node.lets, name, %Let{name: name, body: body})}
  end
  def add_let(node, [head|tail], name, body) do
    case node.children[head] do
      nil -> raise "no child with level #{head} found in #{inspect node}.  Levels: #{inspect [head|tail]}"
      %Describe{} = child ->
        %{node | children: Map.put(node.children, head, add_let(child, tail, name, body))}
    end
  end

  def get_lets(%Describe{} = node, []) do
    node.lets
  end
  def get_lets(node, [head|tail]) do
    case node.children[head] do
      nil -> raise "no child with level #{head} found in #{inspect node}.  Levels: #{inspect [head|tail]}"
      %Describe{} = child ->
        lets = case node do
          %Describe{lets: lets} -> lets
          %Spec{} -> %{}
        end

        Enum.reduce get_lets(child, tail), lets, fn({name, child_let}, lets) ->
          Map.put(lets, name, child_let)
        end
    end
  end
end
