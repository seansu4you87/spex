defmodule Spex.Macros.AgentTest do
  use ExUnit.Case, async: true

  setup do
    Spex.Macros.Agent.start_link
    :ok
  end

  test "pushing and popping stacks" do
    get_stack = fn(mod) ->
      Agent.get(Spex.Macros.Agent, fn(state) ->
        state.stacks[mod]
      end)
    end

    # no stack exists for given module
    assert Spex.Macros.Agent.push_stack(FakeTest, "hello") == ["hello"]
    stack = get_stack.(FakeTest)
    assert stack == ["hello"]

    # stack exists and pushing
    assert Spex.Macros.Agent.push_stack(FakeTest, "world") == ["world", "hello"]
    stack = get_stack.(FakeTest)
    assert stack == ["world", "hello"]

    # popping
    assert Spex.Macros.Agent.pop_stack(FakeTest) == "world"
    stack = get_stack.(FakeTest)
    assert stack == ["hello"]

    # popping
    assert Spex.Macros.Agent.pop_stack(FakeTest) == "hello"
    stack = get_stack.(FakeTest)
    assert stack == []

    # no stack exists and trying to pop
    Spex.Macros.Agent.pop_stack(FakeTest)
  end

  test "getting and putting structures" do
    assert Spex.Macros.Agent.get_structure(FakeTest) == nil

    structure = %Spex.Structure.Spec{}
    assert Spex.Macros.Agent.put_structure(FakeTest, structure) == structure
    assert Spex.Macros.Agent.get_structure(FakeTest) == structure
  end
end
