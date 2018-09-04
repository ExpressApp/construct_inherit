defmodule Construct.Inherit do
  defmacro __using__(_opts \\ []) do
    quote do
      defmacro __using__([do: block]) do
        Construct.Inherit.define(__MODULE__, block)
      end
    end
  end

  def define(base, block) do
    quote do
      use Construct

      structure do
        include unquote(base)
        unquote(block)
      end

      defmacro __using__([do: block]) do
        Construct.Inherit.define(__MODULE__, block)
      end

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
