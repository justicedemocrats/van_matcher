defmodule VanMatcherTest do
  use ExUnit.Case
  doctest VanMatcher

  test "greets the world" do
    assert VanMatcher.hello() == :world
  end
end
