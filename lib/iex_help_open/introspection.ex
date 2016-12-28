# copied and adjusted from:
# https://github.com/elixir-lang/elixir/blob/v1.3.4/lib/iex/lib/iex/introspection.ex
defmodule IExHelpOpen.Introspection do
  @moduledoc false

  import IEx, only: [dont_display_result: 0]

  def h(module) when is_atom(module) do
    case Code.ensure_loaded(module) do
      {:module, _} ->
        if function_exported?(module, :__info__, 1) do
          case Code.get_docs(module, :moduledoc) do
            {_, binary} when is_binary(binary) ->
              {:ok, module}
            {_, _} ->
              {:error, :no_docs}
            _ ->
              {:error, :no_docs}
          end
        else
          {:error, :erlang_module}
        end
      {:error, reason} ->
        {:error, reason}
    end
  end

  def h(_) do
    puts_error("Invalid arguments for h helper")
    dont_display_result
  end

  def h(modules, function) when is_list(modules) and is_atom(function) do
    Enum.map(modules, fn module ->
      case h_mod_fun(module, function) do
        {:ok, _} = result -> result
        _ -> nil
      end
    end)
    |> Enum.find(& &1)
  end

  def h(module, function) when is_atom(module) and is_atom(function) do
    h_mod_fun(module, function)
  end

  defp h_mod_fun(mod, fun) when is_atom(mod) do
    if docs = Code.get_docs(mod, :docs) do
      result = for {{^fun, arity}, _, _, _, _} = doc <- docs, has_content?(doc) do
        h(mod, fun, arity)
      end

      if result != [], do: hd(result), else: {:error, :not_found}
    else
      {:error, :no_docs}
    end
  end

  def h(module, function, arity) when is_atom(module) and is_atom(function) and is_integer(arity) do
    h_mod_fun_arity(module, function, arity)
  end

  def h(modules, function, arity) when is_list(modules) and is_atom(function) and is_integer(arity) do
		Enum.map(modules, fn module ->
			case h_mod_fun_arity(module, function, arity) do
        {:ok, _} = result -> result
        _ -> nil
			end
		end)
    |> Enum.find(& &1)
  end

  defp h_mod_fun_arity(mod, fun, arity) when is_atom(mod) do
    if docs = Code.get_docs(mod, :docs) do
      if find_doc(docs, fun, arity) do
        {:ok, {mod, fun, arity}}
      else
        {:error, :not_found}
      end
    else
      {:error, :no_docs}
    end
  end

  defp find_doc(docs, fun, arity) do
    doc = List.keyfind(docs, {fun, arity}, 0) || find_doc_defaults(docs, fun, arity)
    if has_content?(doc), do: doc
  end

  defp find_doc_defaults(docs, function, min) do
    Enum.find(docs, fn doc ->
      case elem(doc, 0) do
        {^function, arity} when arity > min ->
          defaults = Enum.count(elem(doc, 3), &match?({:\\, _, _}, &1))
          arity <= (min + defaults)
        _ ->
          false
      end
    end)
  end

  defp has_content?(nil),
    do: false
  defp has_content?({_, _, _, _, false}),
    do: false
  defp has_content?({{name, _}, _, _, _, nil}),
    do: hd(Atom.to_charlist(name)) != ?_
  defp has_content?({_, _, _, _, _}),
    do: true

  defp puts_error(string) do
    IO.puts IEx.color(:eval_error, string)
  end
end
