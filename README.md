# Aruspex
Aruspex is a configurable [constraint
solver](https://en.wikipedia.org/wiki/Constraint_satisfaction_problem), written
purely in Elixir.

Aruspex does, or atleast has the capacity to, support multiple constraint problem
satisfaction strategies. Because of this property it is theoretically capable
of supporting various types of CSPs.

At the time of writing Aruspex ships with one strategy, simulated annealing,
which supports weighted CSPs.

**This readme refers to master, please check the readme for your release.**

## Example
```elixir
import Aruspex
use Aruspex.Constraint
{:ok, problem} = start_link
# -> {:ok, #PID<0.149.0>}

problem
# Search strategies are plugable. You're free to implment your own, it just
# needs to implement the `Aruspex.Strategy` behaviour.
|> set_search_strategy(Aruspex.Strategy.SimulatedAnnealing)
|> variable(:x, [2, 4, 6, 8])
|> variable(:y, [1, 2, 3, 5])
# Aruspex also ships with a couple common constraints, like all different.
|> post(all_diff [:x, :y])
|> post(linear rem(^:x, ^:y) == 0)
|> find_solution
# -> [x: 2, y: 1]

problem |> find_solution
# -> [x: 8, y: 1]

problem
|> post(linear ^:y != 1)
|> find_solution
# -> [x: 6, y: 3]

problem
|> find_solution
# -> [x: 8, y: 2]
```

A more complicated example checkout can be found [here](test/aruspex/strategy_test.exs)

## Usage
Check the api exposed by `Aruspex.Server`, all calls to `Aruspex` will be
delegated this module.

### Creating a new problem
Aruspex uses a `GenServer` under the hood, to create a new problem simply use
```elixir
{:ok, pid} = Aruspex.start_link
```

### Defining a new variable
A literal is used to name a new variable, and a domain is specified for the
variable.  This literal will be used to reference the variable later when
defining constraints and will appear in the solution.
```elixir
@spec variable(pid, Literals, Enum.t) :: pid
^pid = Aruspex.variable(pid, :x, 1..100)
```

### Defining a new constraint
Adding a new constraint is called *posting* a constraint. Posting a constraint
requires specifying the variables that participate in the constraint, as well
as a function the returns a *cost* when tested.

Strategies attempt to minimize
the cost of all constraints, where a total cost of 0 would be a perfect
solution.

#### all_diff/1
Constraints may be defined using built in constraints:

```elixir
pid
|> post(all_diff [:x, :y])
```

The `all_diff` constraint would impose a condition that all variables specified
must be unique.

#### linear/1
using the `linear/{1,2}` macro (only supports clauses that can be inlined -
only expressions that can appear in guard clauses):

```elixir
pid
|> post(linear ^:x == ^:y)
```

inside the body of the `linear/1` macro pinned literals indicate that the value
refers to a named variable which will be substituted in during compilation.
pinned variables may also be used to the same effect.

unpinned values will be used by value.

```elixir
some_var = :x
z = 1
pid
|> post(linear ^some_var == ^:y + z)
```

is equivalent to:

```elixir
pid
|> post(linear ^:x == ^:y + 1)
```

#### linear/2
In it's second form, the named variables may be defined explicitly, and matched
on.

```elixir
pid
|> post(linear [:x, :y],
               [{x1, _}, {_, y2}] when x1 == y2)
```

#### constraint/1
User defined constraints are also supported by using the constraint record
directly.

Strategies will test constraints by applying the values for `variables`, in
the order specified, to `function`.

`function` **must** have a type of `[Literals] -> number`.

```elixir
pid
|> post(constraint(
  variables: [:v, :w],
  function: fn ([v, w]) ->
    cond do
      v > 10 ->
        100
      w < 10 ->
        9999
      true ->
       0
    end
  end
))
```
## Roadmap
- [ ] implement more common constraints from [the global constraint catalog](http://www.emn.fr/z-info/sdemasse/gccat/sec5.html).
- [ ] add additional strategies
