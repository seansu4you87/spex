defmodule Spex.Macros do
  use Spex.Structure

  defmacro __using__(_opts) do
    quote do
      import Spex.Macros
      use Spex.Structure

      @spex_stack []
      @spex_structure %Spec{}
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
end
