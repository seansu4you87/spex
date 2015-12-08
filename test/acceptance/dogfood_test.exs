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
  end

end
