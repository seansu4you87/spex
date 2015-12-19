defmodule DogfoodTest do
  use Spex.Case, async: true

  describe "dog fooding" do
    it "passes" do
      assert 1 == 1
    end

    it "passes again" do
      assert 1 == 1
    end

    describe "nesting" do
      it "passes" do
        assert 1 == 1
      end

      xit "would fail, but doesn't run" do
        assert 1 == 2
      end
    end

    describe "let statements" do
      let :memo, do: 1

      it "is callable" do
        assert Spex.Macros.run == [3, 5, 6]
        assert Spex.Macros.run2 == [1, 2]
        # assert memo == 1
      end

      xit "is memoized" do
      end
    end
  end

end
