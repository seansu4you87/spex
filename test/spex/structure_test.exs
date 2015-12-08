defmodule StructureTest do
  use ExUnit.Case, async: true

  import Spex.Structure, only: [add_describe: 2]
  alias Spex.Structure.Spec
  alias Spex.Structure.Spec.Describe

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
