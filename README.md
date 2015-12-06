# Aruspex
Aruspex is a configurable constraint solver, written purely in Elixir.

## Example
```elixir
iex> {:ok, pid} = Aruspex.start_link
{:ok, #PID<0.149.0>}
iex> use Aruspex.Constraint
nil
iex> Aruspex.set_search_strategy pid, Aruspex.Strategy.SimulatedAnnealing
:ok
iex> Aruspex.variable(pid, :x, [2, 4, 6, 8])
:x
iex> Aruspex.variable(pid, :y, [1, 2, 3, 5])
:y
iex> Aruspex.post pid, all_diff([:x, :y])
:ok
iex> Aruspex.post pid, linear(rem(^:x, ^:y) == 0)
:ok
iex> Aruspex.find_solution pid
[x: 2, y: 1]
iex> Aruspex.find_solution pid
[x: 8, y: 1]
iex> Aruspex.post pid, linear(^:y != 1)
:ok
iex> Aruspex.find_solution pid
[x: 6, y: 3]
iex> Aruspex.find_solution pid
[x: 8, y: 2]
```

A more complicated example can be found [here](test/aruspex/strategy_test.exs)

## Usage
Check the api exposed by `Aruspex.Server`, all calls to `Aruspex` will be
delegated to this module.
