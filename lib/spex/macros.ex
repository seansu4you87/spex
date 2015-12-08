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

      @spex_stack []
      @spex_structure %Spex.Structure.Spec{}
    end
  end

  defmacro describe(message, do: body) do
    quote do
      old_stack = @spex_stack
      @spex_stack (old_stack ++ [unquote(message)])

      @spex_structure add_describe(@spex_structure, @spex_stack)
      Module.eval_quoted(__MODULE__, unquote(body))

      @spex_stack old_stack
    end
  end

  defmacro let(name, do: body) do
    code = Macro.to_string(body)
    quote do
      @spex_structure add_let(@spex_structure, @spex_stack, unquote(name), unquote(code))
    end
  end

  defmacro it(message, do: body) do
    quote do
      full_message = Enum.join(@spex_stack ++ [unquote(message)], " ")
      test full_message do
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
