defmodule ConstructInheritTest do
  use ExUnit.Case
  doctest ConstructInherit

  test "greets the world" do
    assert ConstructInherit.hello() == :world
  end
end
