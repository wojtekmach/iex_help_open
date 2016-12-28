# IExHelpOpen

## Usage

```
$ git clone https://github.com/wojtekmach/iex_help_open
$ cd iex_help_open
$ mix archive.build
$ mix archive.install
```

```
$ iex -S mix

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
