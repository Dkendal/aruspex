defmodule Aruspex.Problem do
  import Record
  require Record

  defrecord :csp, graph: nil

  @opaque  constraint  ::  :digraph.edge
  @opaque  t           ::  record(:csp, graph: :digraph.graph)
  @opaque  variable    ::  :digraph.vertex
  @type    binding     ::  %{variable => value}
  @type    domain      ::  Enumerable.t
  @type    value       ::  any

  @spec new :: t
  def new do
    csp graph: :digraph.new
  end

  @spec add_variable(t, variable, domain) :: t
  def add_variable(csp(graph: g) = problem, v, domain) do
    :digraph.add_vertex(g, v, domain)
    problem
  end

  @spec post(t, variable, variable, constraint) :: t
  def post(csp(graph: g) = problem, v1, v2, c) do
    :digraph.add_edge(g, v1, v2, c)
    problem
  end

  def subproblem(csp(graph: g), binding) do
    g = :digraph_utils.subgraph g, Dict.keys(binding)

    csp graph: g
  end

  def degree(csp(graph: p), v),
    do: :digraph.in_degree(p, v) + :digraph.out_degree(p, v)

  def labeled_variables(p, opts \\ []),
    do: variables(p, opts) |> Enum.map(&variable(p, &1))

  def labeled_constraints(p),
    do: constraints(p) |> Enum.map(&constraint(p, &1))

  def variables(p, []), do: variables(p)

  def variables(p, [{:order, :most_constrained} | opts]),
    do: variables(p, opts) |> Enum.sort_by(&degree(p, &1), &>=/2)

  def variables(csp(graph: g)),
    do: :digraph.vertices(g)

  def variable(csp(graph: g), v),
    do: :digraph.vertex(g, v)

  def constraints(csp(graph: g)),
    do: :digraph.edges(g)

  def constraint(csp(graph: g), e),
    do: :digraph.edge(g, e)

  def delete(csp(graph: g)),
    do: :digraph.delete(g)
end
