defmodule StructureTest do
  use ExUnit.Case, async: true

  use Spex.Structure
  alias Spex.Structure.Spec
  alias Spex.Structure.Spec.Describe
  alias Spex.Structure.Spec.Let

  test "#add_let" do
    #first level
    spec = %Spec{}
    levels = []

    levels = levels ++ ["first level"]
    spec = add_describe(spec, levels)
    spec = add_let(spec, levels, :a, quote do: 1 + 1)
    assert spec == %Spec{
      children: %{
        "first level" => %Describe{
          lets: %{
            a: %Let{name: :a, body: quote do: 1 + 1}
          }
        }
      }
    }

    # second level
    levels = levels ++ ["second level"]
    spec = add_describe(spec, levels)
    spec = add_let(spec, levels, :b, quote do: 2 + 1)
    assert spec == %Spec{
      children: %{
        "first level" => %Describe{
          children: %{
            "second level" => %Describe{
              lets: %{
                b: %Let{name: :b, body: quote do: 2 + 1}
              }
            }
          },
          lets: %{
            a: %Let{name: :a, body: quote do: 1 + 1}
          }
        }
      }
    }
  end

  @tag :seanyu
  test "#get_lets" do
    #first level
    spec = %Spec{}
    levels = []

    levels = levels ++ ["first level"]
    spec = add_describe(spec, levels)
    spec = add_let(spec, levels, :a, quote do: 1 + 1)
    spec = add_let(spec, levels, :override, quote do: %{empty: true})
    assert get_lets(spec, levels) == %{
      a: %Let{name: :a, body: quote do: 1 + 1},
      override: %Let{name: :override, body: quote do: %{empty: true}}
    }

    # second level
    levels = levels ++ ["second level"]
    spec = add_describe(spec, levels)
    spec = add_let(spec, levels, :b, quote do: 2 + 1)
    spec = add_let(spec, levels, :override, quote do: %{empty: false})
    assert get_lets(spec, levels) == %{
      a: %Let{name: :a, body: quote do: 1 + 1},
      b: %Let{name: :b, body: quote do: 2 + 1},
      override: %Let{name: :override, body: quote do: %{empty: false}}
    }
  end

  test "#add_describe" do
    # first level
    spec = %Spec{}
    levels = []

    levels = levels ++ ["first level"]
    spec = add_describe(spec, levels)
    assert spec == %Spec{
      children: %{
        "first level" => %Describe{}
      }
    }

    # second level
    levels = levels ++ ["second level"]
    spec = add_describe(spec, levels)
    assert spec == %Spec{
      children: %{
        "first level" => %Describe{
          children: %{
            "second level" => %Describe{}
          }
        }
      }
    }

    # third level
    levels = levels ++ ["third level"]
    spec = add_describe(spec, levels)
    assert spec == %Spec{
      children: %{
        "first level" => %Describe{
          children: %{
            "second level" => %Describe{
              children: %{
                "third level" => %Describe{}
              }
            }
          }
        }
      }
    }

    # second level b
    levels = List.delete_at(levels, -1)
    levels = List.delete_at(levels, -1)
    levels = levels ++ ["second level b"]
    spec = add_describe(spec, levels)
    assert spec == %Spec{
      children: %{
        "first level" => %Describe{
          children: %{
            "second level" => %Describe{
              children: %{
                "third level" => %Describe{}
              }
            },
            "second level b" => %Describe{}
          }
        }
      }
    }
  end
end
