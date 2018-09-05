defmodule Construct.Inherit do
  defmacro __using__(opts \\ []) do
    make_inherit = Keyword.get(opts, :make_inherit, false)

    quote do
      defmacro __using__(opts \\ []) do
        Construct.Inherit.define(__MODULE__, unquote(make_inherit), Keyword.get(opts, :do))
      end
    end
  end

  def define(base, make_inherit, block) do
    quote do
      use Construct

      import Construct.Inherit

      @base unquote(base)

      if unquote(block != nil) do
        override do
          unquote(block)
        end
      end

      defmacro __using__(opts \\ []) do
        Construct.Inherit.define(__MODULE__, unquote(make_inherit), Keyword.get(opts, :do))
      end

      if unquote(make_inherit) do
        def make(params, opts) do
          with {:ok, map} <- super(params, opts),
              {:ok, inherit} <- unquote(base).make(map, opts)
          do
            {:ok, struct(__MODULE__, Map.from_struct(inherit))}
          end
        end

        defoverridable [make: 2]
      end
    end
  end

  defmacro override([do: block]) do
    quote do
      structure do
        include @base
        unquote(block)
      end
    end
  end

  defmacro override(path, [do: block]) do
    quote do
      structure do
        include @base
        unquote(path_ast(path, block))
      end
    end
  end

  defp path_ast([], block) do
    block
  end
  defp path_ast([path|rest], block) do
    {:field, [], [path, [do: path_ast(rest, block)]]}
  end
  defp path_ast(path, block) when is_atom(path) do
    {:field, [], [path, [do: block]]}
  end
end
