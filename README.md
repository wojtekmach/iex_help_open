# IExHelpOpen

Similar to IEx's `h` but instead of printing documentation it opens it in a browser window.

## Usage

```
# install iex_help_open
$ mix archive.install https://github.com/wojtekmach/iex_help_open/releases/download/v0.1.0/iex_help_open-0.1.0.ez

# use it in a mix project
$ iex -S mix
iex> import_if_available IExHelpOpen # or add this line to .iex.exs

iex> ho inspect
# opens https://hexdocs.pm/elixir/Kernel.html#inspect/2

iex> ho Ecto.Changeset.cast/3
# opens https://hexdocs.pm/ecto/Ecto.Changeset.html#cast/3
```

## Known limitations

- works only with Mix
- does not handle errors well
- does not support callbacks
- does not support types

## License

MIT
