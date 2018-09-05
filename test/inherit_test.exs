defmodule InheritTest do
  use ExUnit.Case

  defmodule Test00 do
    use Construct
    use Construct.Inherit

    structure do
      field :a, :integer
      field :b do
        field :c, :map, default: nil
      end
    end
  end

  defmodule Test01 do
    use Test00

    override [:b, :c] do
      field :foo, :string
      field :bar, :integer, default: 0
    end
  end

  defmodule Test10 do
    use Construct
    use Construct.Inherit, make_inherit: true

    structure do
      field :a, :integer
      field :b, :string, default: "test10"
    end

    def make(params, opts) do
      with {:ok, map} <- super(params, opts) do
        {:ok, %{map|b: %{inner: map.b}}}
      end
    end
  end

  defmodule Test11 do
    use Test10 do
      field :b, :string, default: "test11"
    end
  end

  defmodule Test12 do
    use Test11 do
      field :b, :string, default: "test12"
      field :c, :integer, default: 42
    end

    def make(params, opts) do
      with {:ok, map} <- super(params, opts) do
        {:ok, %{map|c: %{inner: map.c}}}
      end
    end
  end

  defmodule Test13 do
    use Test12

    override do
      field :b, :string, default: "test13"
    end
  end

  test "fields overriding" do
    assert {:ok, %Test00{a: 1, b: %Test00.B{c: nil}}}
        == Test00.make(a: 1, b: %{})

    assert {:ok, %Test01{a: 1, b: %Test01.B{c: %Test01.B.C{bar: 0, foo: "test"}}}}
        == Test01.make(a: 1, b: %{c: %{foo: "test"}})

  end

  test "make inheritance" do
    assert {:ok, %Test10{a: 1, b: %{inner: "test10"}}}
        == Test10.make(a: 1)

    assert {:ok, %Test11{a: 1, b: %{inner: "test11"}}}
        == Test11.make(a: 1)

    assert {:ok, %Test12{a: 1, c: %{inner: 42}, b: %{inner: "test12"}}}
        == Test12.make(a: 1)

    assert {:ok, %Test13{a: 1, c: %{inner: 42}, b: %{inner: "test13"}}}
        == Test13.make(a: 1)

  end
end
