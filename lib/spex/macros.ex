defmodule Spex.Macros do
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

  defmacro it(message, do: body) do
    quote do
      full_message = Enum.join(@spex_stack ++ [unquote(message)], " ")
      test full_message, do: unquote(body)
    end
  end

  defmacro xit(message, do: body) do
    quote do
      @tag :pending
      it unquote(message), do: unquote(body)
    end
  end
end
