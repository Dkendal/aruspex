# Changelog
Please include an addition to this file with all pull requests.

## Unpublished
- Strategies are now implemented as protocols, options for a strategy is set on
  the strategy struct, which is then called by strat to solve the problem.
  The only user facing change to this is `set_strategy/2`
  ```
  # was
  set_strategy problem, My.Strategy
  # now
  set_strategy problem, %My.Strategy{}
  ```
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
