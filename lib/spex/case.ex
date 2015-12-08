defmodule Spex.Case do
  defmacro __using__(opts \\ []) do
    async = Keyword.get(opts, :async, false)
    quote do
      use ExUnit.Case, async: unquote(async)
      use Spex.Macros
    end
  end
end
