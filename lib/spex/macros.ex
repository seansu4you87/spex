defmodule Spex.Macros do
  @moduledoc """
  defines the following macros:
  - describe (xdescribe)
  - context (xcontext)
  - before
  - let
  - it (xit)

  it examples like:

      describe Calculator do
        let(:a), do: 1
        describe "#add" do
          let(:b), do: 1 + 1

          it "adds correctly" do
            assert a + b == 3
          end
        end
      end

  will become:

      test "Calculator #add adds correctly" do
        a = (fn ->
          1
        end).()

        b = (fn ->
          1 + 1
        end).()

        assert a + b == 3
      end
  """

  use Spex.Structure

  defmacro __using__(_opts) do
    quote do
      use Spex.Structure
      import Spex.Macros

      Spex.Macros.Agent.put_structure(__MODULE__, %Spex.Structure.Spec{})
    end
  end

  defmacro describe(message, do: body) do
    quote do
      stack = Spex.Macros.Agent.push_stack(__MODULE__, unquote(message))
      structure = Spex.Macros.Agent.get_structure(__MODULE__)
      structure_with_describe = add_describe(structure, Enum.reverse(stack))
      Spex.Macros.Agent.put_structure(__MODULE__, structure_with_describe)
      Module.eval_quoted(__MODULE__, unquote(body))
      Spex.Macros.Agent.pop_stack(__MODULE__)
    end
  end

  defmacro let(name, do: body) do
    code = Macro.to_string(body)
    quote do
      reversed_stack = Enum.reverse(Spex.Macros.Agent.get_stack(__MODULE__))
      structure = Spex.Macros.Agent.get_structure(__MODULE__)
      structure_with_let = add_let(structure, reversed_stack, unquote(name), unquote(code))
      Spex.Macros.Agent.put_structure(__MODULE__, structure_with_let)
    end
  end

  defmacro initialize_to_char_count(variables) do
    Enum.map variables, fn(name) ->
      var = Macro.var(name, nil)
      length = name |> Atom.to_string |> String.length
      quote do
        unquote(var) = unquote(length)
      end
    end
  end

  def run do
    initialize_to_char_count [:red, :green, :yellow]
    [red, green, yellow]
  end

  defmacro deflet(name, value) do
    var = Macro.var(name, nil)
    quote do
      unquote(var) = unquote(value)
    end
  end

  defmacro deflets(lets) do
    Enum.map lets, fn({name, value}) ->
      IO.puts "wtf #{inspect name}, #{inspect value}"
      quote do
        deflet unquote(name), unquote(value)
      end
    end
  end

  def run2 do
    deflets [red: 1, blue: 2]
    # deflet :red, 1
    # deflet :blue, 2
    [red, blue]
  end

  defmacro it(message, do: body) do
    IO.puts "COMPILE TIME"
    quote do
      reversed_stack = Enum.reverse(Spex.Macros.Agent.get_stack(__MODULE__))
      structure = Spex.Macros.Agent.get_structure(__MODULE__)

      lets = get_lets(structure, reversed_stack)
      lets_keywords = Enum.reduce lets, [], fn({_key, let}, list) ->
        list ++ [{let.name, let.body}]
      end
      IO.puts "WTF #{inspect lets_keywords}"

      full_message = Enum.join(reversed_stack ++ [unquote(message)], " ")

      test full_message do
        IO.puts "RUN TIME it #{__MODULE__}"
        # deflets unquote(lets_keywords)

        unquote(body)
      end
    end
  end

  defmacro xit(message, do: body) do
    quote do
      @tag :pending
      it unquote(message), do: unquote(body)
    end
  end
end
