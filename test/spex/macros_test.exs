defmodule MacrosTest do
  use ExUnit.Case, async: true
  use Spex.Macros

  setup do
    :ok
  end

  test "describe macro keeps track of position in a stack" do
    defmodule DescribeStackTest do
      use Spex.Macros

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
      use Spex.Macros

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
end
