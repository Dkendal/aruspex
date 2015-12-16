# Changelog
Please include an addition to this file with all pull requests.

## Unpublished
- `Aruspex` no longer delegates it's api to `Aruspex.Server`, please use
  `Aruspex.Server` directly instead.
- Changes to `Aruspex.Server`'s API, `post/2`, `variable/2`, and
  `set_search_strategy/2` now return the same `pid` used as the first argument.
  This change allows for cleaner API usage:
  ```elixir
  pid
  |> variable(:x, 1..2)
  |> variable(:y, 1..2)
  |> post(linear :x + :y == 1)
  |> find_solution
  ```
