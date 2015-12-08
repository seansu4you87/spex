defmodule Spex do
  def start do
    ExUnit.configure(exclude: [pending: true])
    ExUnit.start
  end
end
