defmodule InheritTest do
  use ExUnit.Case

  defmodule Test00 do
    use Construct
    use Construct.Inherit

    structure do
      field :a, :integer
      field :b do
        field :c, :map, default: nil
        field :d do
          field :e, :string, default: "deeper"
        end
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

  defmodule Test02 do
    use Test00

    override do
      field :a, :integer, default: 42
    end
  end

  defmodule Test03 do
    use Test00

    override [:b, :d, :e], :integer
  end

  defmodule Test04 do
    use Test00

    override [:b, :d, :e], :string, default: "overridden"
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

  describe "fields overriding" do
    test "ensure that root structure is valid" do
      assert {:ok, %Test00{a: 1, b: %Test00.B{c: nil, d: %Test00.B.D{e: "deeper"}}}}
          == Test00.make(a: 1, b: %{d: %{}})
    end

    test "override nested fields" do
      assert {:ok, %Test01{a: 1, b: %Test01.B{c: %Test01.B.C{bar: 0, foo: "test"}, d: %Test00.B.D{e: "deeper"}}}}
          == Test01.make(a: 1, b: %{c: %{foo: "test"}, d: %{}})
    end

    test "override root fields" do
      assert {:ok, %Test02{a: 42, b: %Test00.B{c: %{foo: "test"}, d: %Test00.B.D{e: "deeper"}}}}
          == Test02.make(b: %{c: %{foo: "test"}, d: %{}})
    end

    test "override single nested field with type only" do
      assert {:ok, %Test03{a: 1, b: %Test03.B{c: nil, d: %Test03.B.D{e: 42}}}}
          == Test03.make(a: 1, b: %{d: %{e: 42}})
    end

    test "override single nested field with type and options" do
      assert {:ok, %Test04{a: 1, b: %Test04.B{c: nil, d: %Test04.B.D{e: "overridden"}}}}
          == Test04.make(a: 1, b: %{d: %{}})
    end
  end

  describe "make inheritance" do
    test "level 0" do
      assert {:ok, %Test10{a: 1, b: %{inner: "test10"}}}
          == Test10.make(a: 1)
    end

    test "level 1" do
      assert {:ok, %Test11{a: 1, b: %{inner: "test11"}}}
          == Test11.make(a: 1)
    end

    test "level 2" do
      assert {:ok, %Test12{a: 1, c: %{inner: 42}, b: %{inner: "test12"}}}
          == Test12.make(a: 1)
    end

    test "level 3" do
      assert {:ok, %Test13{a: 1, c: %{inner: 42}, b: %{inner: "test13"}}}
          == Test13.make(a: 1)
    end
  end
end
