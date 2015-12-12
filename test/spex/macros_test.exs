defmodule MacrosTest do
  use ExUnit.Case, async: true

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

      @get_stack fn ->
        Agent.get(Spex.Macros.Agent, fn(state) ->
          Enum.reverse(state.stacks[DescribeStackTest])
        end)
      end


      describe "first level" do
        @first_stack @get_stack.()
        def first_stack, do: @first_stack

        describe "second level" do
          @second_stack @get_stack.()
          def second_stack, do: @second_stack

          describe "third level" do
            @third_stack @get_stack.()
            def third_stack, do: @third_stack
          end

          @third_stack_end @get_stack.()
          def third_stack_end, do: @third_stack_end
        end

        @second_stack_end @get_stack.()
        def second_stack_end, do: @second_stack_end

        describe "second level b" do
          @second_stack_b @get_stack.()
          def second_stack_b, do: @second_stack_b
        end

        @second_stack_b_end @get_stack.()
        def second_stack_b_end, do: @second_stack_b_end

      end

      @first_stack_end @get_stack.()
      def first_stack_end, do: @first_stack_end
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

      @get_structure fn ->
        Agent.get(Spex.Macros.Agent, fn(state) ->
          state.structures[DescribeStructureTest]
        end)
      end

      @start_spec @get_structure.()
      def start_spec, do: @start_spec

      describe "first level" do
        @first_spec @get_structure.()
        def first_spec, do: @first_spec

        describe "second level" do
          @second_spec @get_structure.()
          def second_spec, do: @second_spec

          describe "third level" do
            @third_spec @get_structure.()
            def third_spec, do: @third_spec
          end
        end

        describe "second level b" do
          @second_spec_b @get_structure.()
          def second_spec_b, do: @second_spec_b
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

      @get_structure fn ->
        Agent.get(Spex.Macros.Agent, fn(state) ->
          state.structures[LetStructureTest]
        end)
      end

      @start_spec @get_structure.()
      def start_spec, do: @start_spec

      describe "first level" do
        let :first_level_let_1 do
          IO.puts "-------------------------FUCK------------------------"
          0 + 0
          1 + 1
          2 + 2
        end

        @first_spec @get_structure.()
        def first_spec, do: @first_spec

        describe "second level" do
          let :second_level_let_1, do: 1 + 1
          @second_spec @get_structure.()
          def second_spec, do: @second_spec

          describe "third level" do
            let :third_level_let_1, do: 2 + 1
            @third_spec @get_structure.()
            def third_spec, do: @third_spec
          end
        end

        describe "second level b" do
          let :second_level_b_let_1, do: "buganu"
          @second_spec_b @get_structure.()
          def second_spec_b, do: @second_spec_b
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
