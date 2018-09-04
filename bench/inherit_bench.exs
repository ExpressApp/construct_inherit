defmodule InheritBench do
  use Benchfella

  defmodule Test1 do
    use Construct
    use Construct.Inherit

    structure do
      field :a, :integer
      field :b, :string, default: "test1"
    end

    def make(params, opts) do
      with {:ok, map} <- super(params, opts) do
        {:ok, %{map|b: %{inner: map.b}}}
      end
    end
  end

  defmodule Test2 do
    use Test1 do
      field :b, :string, default: "test2"
    end
  end

  defmodule Test3 do
    use Test2 do
      field :b, :string, default: "test3"
      field :c, :integer, default: 42
    end

    def make(params, opts) do
      with {:ok, map} <- super(params, opts) do
        {:ok, %{map|c: %{inner: map.c}}}
      end
    end
  end

  defmodule Test4 do
    use Test3 do
      field :b, :string, default: "test4"
    end
  end

  defmodule Test5 do
    use Test4 do
      field :b, :string, default: "test5"
    end
  end

  bench "Test1" do
    {:ok, %Test1{a: 1, b: %{inner: "test1"}}}
      == Test1.make(a: 1)
  end

  bench "Test2" do
    {:ok, %Test2{a: 1, b: %{inner: "test2"}}}
      == Test2.make(a: 1)
  end

  bench "Test3" do
    {:ok, %Test3{a: 1, c: %{inner: 42}, b: %{inner: "test3"}}}
      == Test3.make(a: 1)
  end

  bench "Test4" do
    {:ok, %Test4{a: 1, c: %{inner: 42}, b: %{inner: "test4"}}}
      == Test4.make(a: 1)
  end

  bench "Test5" do
    {:ok, %Test5{a: 1, c: %{inner: 42}, b: %{inner: "test5"}}}
      == Test5.make(a: 1)
  end
end
