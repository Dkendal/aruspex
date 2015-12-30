defmodule Aruspex.Problem do
  @opaque  constraint  ::  :digraph.edge
  @opaque  t           ::  :digraph.graph
  @opaque  variable    ::  :digraph.vertex
  @type    binding     ::  %{variable => value}
  @type    domain      ::  Enumerable.t
  @type    value       ::  any

  import :digraph, only: [
    add_edge: 4,
    add_vertex: 3,
    in_degree: 2,
    out_degree: 2
  ]

  import :digraph_utils, only: [
    subgraph: 2
  ]

  @spec new :: t
  def new do
    :digraph.new
  end

  @spec add_variable(t, variable, domain) :: t
  def add_variable(problem, v, domain) do
    add_vertex(problem, v, domain)
    problem
  end

  @spec post(t, variable, variable, constraint) :: t
  def post(problem, v1, v2, c) do
    problem
    |> add_edge(v1, v2, c)
    problem
  end

  def subproblem(problem, binding) do
    :digraph_utils.subgraph problem, Dict.keys(binding)
  end

  def degree(p, v),
    do: in_degree(p, v) + out_degree(p, v)

  def labeled_variables(p, opts \\ []),
    do: variables(p, opts) |> Enum.map(&variable(p, &1))

  def labeled_constraints(p),
    do: constraints(p) |> Enum.map(&constraint(p, &1))

  def variables(p, []), do: variables(p)

  def variables(p, [{:order, :most_constrained} | opts]),
    do: variables(p, opts) |> Enum.sort_by(&degree(p, &1), &>=/2)

  defdelegate variables(problem), to: :digraph, as: :vertices

  defdelegate variable(problem, v), to: :digraph, as: :vertex
  defdelegate constraints(problem), to: :digraph, as: :edges
  defdelegate constraint(problem, e), to: :digraph, as: :edge
  defdelegate delete(problem), to: :digraph
end
