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
Given a map of Australia, find some colouring of teritories, such that no adjacent territory has the same colour.

![](http://australia.pppst.com/Australia_map_regions.gif)

```elixir
import Aruspex.Server
use Aruspex.Constraint

{:ok, problem} = start_link

variables = [
  wa  = :western_australia,
  nt  = :nothern_territory,
  q   = :queensland,
  sa  = :south_australia,
  nsw = :new_south_wales,
  v   = :victoria,
  t   = :tasmania
]

domain = [:red, :green, :blue]

Enum.map variables, &(variable problem, &1, domain)

problem
|> set_search_strategy(Aruspex.Strategy.SimulatedAnnealing)
# adjacent territories cannot be the same colour
# The pin operator is used to reference a named variable in a constraint, check the section on variables below.
|> post(linear ^wa != ^nt)
|> post(linear ^wa != ^sa)
|> post(linear ^sa != ^nt)
|> post(linear ^sa != ^q)
|> post(linear ^sa != ^nsw)
|> post(linear ^sa != ^v)
|> post(linear ^nt != ^q)
|> post(linear ^q != ^nsw)
|> post(linear ^nsw != ^v)
|> find_solution
|> IO.inspect
# [ new_south_wales:    :blue,
#   nothern_territory:  :blue,
#   queensland:         :green,
#   south_australia:    :red,
#   tasmania:           :green,
#   victoria:           :green,
#   western_australia:  :green ]
```

For some more examples checkout [these.](test/support/examples/)

## Usage
Check the api exposed by `Aruspex.Server`

### Creating a new problem
Aruspex uses a `GenServer` under the hood, to create a new problem simply use
```elixir
{:ok, pid} = Aruspex.Server.start_link
```

### Defining a new variable
A literal is used to name a new variable, and a domain is specified for the
variable.  This literal will be used to reference the variable later when
defining constraints and will appear in the solution.
```elixir
@spec variable(pid, Literals, Enum.t) :: pid
^pid = Aruspex.Server.variable(pid, :x, 1..100)
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
- [ ] configurable settings for s.a. strategy (run time, cooling strategy, etc.)
- [ ] configurable tolerance for what is an acceptable solution (default is only perfect solutions)
- [ ] allow strategies to return multiple soltuions with message box.
- [ ] allow multiple strategies to be employed, which will act as middlewear.
- [ ] user defined optimization tolerance
- [ ] implement more common constraints from [the global constraint catalog](http://www.emn.fr/z-info/sdemasse/gccat/sec5.html).
- [ ] add additional strategies
