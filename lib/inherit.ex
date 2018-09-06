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

      alias unquote(base), as: Base_
      import Construct.Inherit

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
        include(unquote(make_base_module_name_ast([])))
        unquote(block)
      end
    end
  end

  defmacro override(path, [do: block]) do
    quote do
      structure do
        unquote(path_ast(path, [], block))
      end
    end
  end

  defp path_ast([], as, block) do
    {:__block__, [], [
      include_base_ast(as),
      block
    ]}
  end
  defp path_ast([path|rest], as, block) do
    current_as = as ++ [path]

    {:__block__, [], [
      include_base_ast(as),
      {:field, [], [path, [do: path_ast(rest, current_as, block)]]}
    ]}
  end
  defp path_ast(path, as, block) when is_atom(path) do
    {:field, [], [path, [do: path_ast([], as, block)]]}
  end

  defp include_base_ast(nest) do
    module_name_ast = make_base_module_name_ast(Enum.map(nest, &upcase_atom/1))

    quote do
      if Code.ensure_compiled?(unquote(module_name_ast)), do:
        include(unquote(module_name_ast))
    end
  end

  defp upcase_atom(atom) do
    atom |> to_string |> Macro.camelize |> String.to_atom
  end

  defp make_base_module_name_ast(atoms) when is_list(atoms) do
    {:__aliases__, [], [:Base_ | atoms]}
  end
end
