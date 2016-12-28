defmodule IExHelpOpenTest do
  use ExUnit.Case
  import IExHelpOpen
  import IExHelpOpen.Browser

  test "o" do
    assert o(Map) == {:ok, Map}
    assert o(Map.new) == {:ok, {Map, :new, 0}}
    assert o(Map.new/0) == {:ok, {Map, :new, 0}}
    assert o(Map.new/1) == {:ok, {Map, :new, 1}}
    assert o(Map.new/9) == {:error, :not_found}
    assert o(Map.bad) == {:error, :not_found}
    assert o(Bad.bad) == {:error, :no_docs}
    assert o(Bad) == {:error, :nofile}

    assert o(inspect) == {:ok, {Kernel, :inspect, 2}}
    assert o(inspect/2) == {:ok, {Kernel, :inspect, 2}}
  end

  test "app" do
    assert app(Map) == :elixir
    assert app(IExHelpOpen) == :iex_help_open
  end

  test "url" do
    assert url(:elixir, Map) == "https://hexdocs.pm/elixir/Map.html"
    assert url(:elixir, {Map, :new, 0}) == "https://hexdocs.pm/elixir/Map.html#new/0"

    assert url(:ecto, {Ecto.Changeset, :cast, 3}) == "https://hexdocs.pm/ecto/Ecto.Changeset.html#cast/3"
  end
end
