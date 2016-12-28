defmodule IExHelpOpen do
	# Copied and adjusted from:
	# https://github.com/elixir-lang/elixir/blob/v1.3.4/lib/iex/lib/iex/helpers.ex#L186:L223
  @h_modules [__MODULE__, Kernel, Kernel.SpecialForms]
  import IEx, only: [dont_display_result: 0]

  @doc """
  Opens the documentation for the given module or for the given function/arity
  pair in a browser window.

  ## Examples

      iex> ho inspect
      # opens https://hexdocs.pm/elixir/Kernel.html#inspect/2

      iex> ho Ecto.Changeset.cast/3
      # opens https://hexdocs.pm/ecto/Ecto.Changeset.html#cast/3
  """
  defmacro ho(term) do
    quote do
      {:ok, result} = o(unquote(term))
      app = app(result)
      IExHelpOpen.Browser.url(app, result)
      |> IExHelpOpen.Browser.open
      dont_display_result()
    end
  end

  @doc false
  defmacro o(term)
  defmacro o({:/, _, [call, arity]} = term) do
    args =
      case Macro.decompose_call(call) do
        {_mod, :__info__, []} when arity == 1 ->
          [Module, :__info__, 1]
        {mod, fun, []} ->
          [mod, fun, arity]
        {fun, []} ->
          [@h_modules, fun, arity]
        _ ->
          [term]
      end

    quote do
      IExHelpOpen.Introspection.h(unquote_splicing(args))
    end
  end

  defmacro o(call) do
    args =
      case Macro.decompose_call(call) do
        {_mod, :__info__, []} ->
          [Module, :__info__, 1]
        {mod, fun, []} ->
          [mod, fun]
        {fun, []} ->
          [@h_modules, fun]
        _ ->
          [call]
      end

    quote do
      IExHelpOpen.Introspection.h(unquote_splicing(args))
    end
  end

  @doc false
  def app(mod) when is_atom(mod) do
    Enum.find(Application.loaded_applications, fn {app, _, _} ->
      mod in Keyword.fetch!(Application.spec(app), :modules)
    end)
    |> elem(0)
  end
  def app({mod, _, _}), do: app(mod)
end

defmodule IExHelpOpen.Browser do
	@moduledoc false

  @hexdocs "https://hexdocs.pm/"

  def url(app, mod) when is_atom(app) and is_atom(mod),
    do: @hexdocs <> "#{app}/#{inspect mod}.html"
  def url(app, {mod, fun, arity}) when is_atom(app),
    do: @hexdocs <> "#{app}/#{inspect mod}.html##{fun}/#{arity}"

	# Copied and adjusted from:
	# https://github.com/hexpm/hex/blob/v0.15.0/lib/mix/tasks/hex/docs.ex#L157:L173
  def open(url) do
    start_browser_command =
      case :os.type do
        {:win32, _} ->
          "start"
        {:unix, :darwin} ->
          "open"
        {:unix, _} ->
          "xdg-open"
      end

    if System.find_executable(start_browser_command) do
      System.cmd(start_browser_command, [url])
    else
      Mix.raise "Command not found: #{start_browser_command}"
    end
  end
end
