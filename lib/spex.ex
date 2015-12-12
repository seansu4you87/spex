defmodule Spex do
  def start do
    Spex.Macros.Agent.start_link

    ExUnit.configure(exclude: [pending: true])
    ExUnit.start
  end
end
