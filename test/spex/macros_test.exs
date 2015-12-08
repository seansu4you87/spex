defmodule MacrosTest do
  use Spex.Case, async: true

  alias Spex.Structure.Spec
  alias Spex.Structure.Spec.Describe
  alias Spex.Structure.Spec.Let

  setup do
    :ok
  end

  # defmodule REPLACE_ME_Test do
  #   use Spex.Case, async: true

  #   describe "first level" do
  #     describe "second level" do
  #       describe "third level" do
  #       end
  #     end
  #     describe "second level b" do
  #     end
  #   end
  # end

  test "describe macro keeps track of position in a stack" do
    defmodule DescribeStackTest do
      use Spex.Case, async: true

      describe "first level" do
        def first_stack, do: @spex_stack

        describe "second level" do
          def second_stack, do: @spex_stack

          describe "third level" do
            def third_stack, do: @spex_stack
          end

          def third_stack_end, do: @spex_stack
        end
        def second_stack_end, do: @spex_stack

        describe "second level b" do
          def second_stack_b, do: @spex_stack
        end
        def second_stack_b_end, do: @spex_stack

      end

      def first_stack_end, do: @spex_stack
    end

    assert DescribeStackTest.first_stack == ["first level"]
    assert DescribeStackTest.second_stack == ["first level", "second level"]
    assert DescribeStackTest.third_stack == ["first level", "second level", "third level"]
    assert DescribeStackTest.third_stack_end == ["first level", "second level"]
    assert DescribeStackTest.second_stack_end == ["first level"]
    assert DescribeStackTest.second_stack_b == ["first level", "second level b"]
    assert DescribeStackTest.second_stack_b_end == ["first level"]
    assert DescribeStackTest.first_stack_end == []
  end

  test "describe macro keeps track of spec in a structure" do
    defmodule DescribeStructureTest do
      use Spex.Case, async: true

      def start_spec, do: @spex_structure

      describe "first level" do
        def first_spec, do: @spex_structure

        describe "second level" do
          def second_spec, do: @spex_structure

          describe "third level" do
            def third_spec, do: @spex_structure
          end
        end

        describe "second level b" do
          def second_spec_b, do: @spex_structure
        end
      end
    end

    assert DescribeStructureTest.start_spec == %Spec{}
    assert DescribeStructureTest.first_spec == %Spec{
      children: %{
        "first level" => %Describe{}
      }
    }
    assert DescribeStructureTest.second_spec == %Spec{
      children: %{
        "first level" => %Describe{
          children: %{
            "second level" => %Describe{}
          }
        }
      }
    }
    assert DescribeStructureTest.third_spec == %Spec{
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
    assert DescribeStructureTest.second_spec_b == %Spec{
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

  test "let macro keeps track of spec in a structure" do
    defmodule LetStructureTest do
      use Spex.Case, async: true

      def start_spec, do: @spex_structure

      describe "first level" do
        let :first_level_let_1 do
          IO.puts "-------------------------FUCK------------------------"
          0 + 0
          1 + 1
          2 + 2
        end

        def first_spec, do: @spex_structure

        describe "second level" do
          let :second_level_let_1, do: 1 + 1
          def second_spec, do: @spex_structure

          describe "third level" do
            let :third_level_let_1, do: 2 + 1
            def third_spec, do: @spex_structure
          end
        end

        describe "second level b" do
          let :second_level_b_let_1, do: "buganu"
          def second_spec_b, do: @spex_structure
        end
      end
    end

    first_level_let_1_body = Macro.to_string(quote do
      IO.puts "-------------------------FUCK------------------------"
      0 + 0
      1 + 1
      2 + 2
    end)
    second_level_let_1_body = Macro.to_string(quote do: 1 + 1)
    third_level_let_1_body = Macro.to_string(quote do: 2 + 1)
    second_level_b_let_1_body = Macro.to_string(quote do: "buganu")

    assert LetStructureTest.start_spec == %Spec{}
    assert LetStructureTest.first_spec == %Spec{
      children: %{
        "first level" => %Describe{
          lets: %{
            first_level_let_1: %Let{name: :first_level_let_1, body: first_level_let_1_body}
          }
        }
      }
    }
    assert LetStructureTest.second_spec == %Spec{
      children: %{
        "first level" => %Describe{
          children: %{
            "second level" => %Describe{
              lets: %{
                second_level_let_1: %Let{name: :second_level_let_1, body: second_level_let_1_body}
              }
            }
          },
          lets: %{
            first_level_let_1: %Let{name: :first_level_let_1, body: first_level_let_1_body}
          }
        }
      }
    }
    assert LetStructureTest.third_spec == %Spec{
      children: %{
        "first level" => %Describe{
          children: %{
            "second level" => %Describe{
              children: %{
                "third level" => %Describe{
                  lets: %{
                    third_level_let_1: %Let{name: :third_level_let_1, body: third_level_let_1_body}
                  }
                }
              },
              lets: %{
                second_level_let_1: %Let{name: :second_level_let_1, body: second_level_let_1_body}
              }
            }
          },
          lets: %{
            first_level_let_1: %Let{name: :first_level_let_1, body: first_level_let_1_body}
          }
        }
      }
    }
    assert LetStructureTest.second_spec_b == %Spec{
      children: %{
        "first level" => %Describe{
          children: %{
            "second level" => %Describe{
              children: %{
                "third level" => %Describe{
                  lets: %{
                    third_level_let_1: %Let{name: :third_level_let_1, body: third_level_let_1_body}
                  }
                }
              },
              lets: %{
                second_level_let_1: %Let{name: :second_level_let_1, body: second_level_let_1_body}
              }
            },
            "second level b" => %Describe{
              lets: %{
                second_level_b_let_1: %Let{name: :second_level_b_let_1, body: second_level_b_let_1_body}
              }
            }
          },
          lets: %{
            first_level_let_1: %Let{name: :first_level_let_1, body: first_level_let_1_body}
          }
        }
      }
    }
  end

  test "it macro creates test functions" do
    defmodule ItTest do
      use Spex.Case, async: true

      describe "first level" do
        it "example 1-a", do: assert 1 == 1
        it "example 1-b", do: assert 1 == 2

        describe "second level" do
          it "example 2-a", do: assert 1 == 1
          it "example 2-b", do: assert 1 == 2

          describe "third level" do
            it "example 3-a", do: assert 1 == 1
            it "example 3-b", do: assert 1 == 2
          end
        end

        describe "second level b" do
            it "example 2b-a", do: assert 1 == 1
            it "example 2b-b", do: assert 1 == 2
        end
      end
    end

    funs = ItTest.__info__(:functions)
    assert funs[:"test first level example 1-a"] == 1
    assert funs[:"test first level example 1-b"] == 1
    assert funs[:"test first level second level example 2-a"] == 1
    assert funs[:"test first level second level example 2-b"] == 1
    assert funs[:"test first level second level third level example 3-a"] == 1
    assert funs[:"test first level second level third level example 3-b"] == 1
    assert funs[:"test first level second level b example 2b-a"] == 1
    assert funs[:"test first level second level b example 2b-b"] == 1
  end
end
