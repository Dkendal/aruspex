defmodule Aruspex.Problem do
  import Record
  require Record

  defrecord :csp, graph: nil
  defrecord :hidden, id: nil, variables: nil

  @opaque  constraint  ::  (... -> boolean | number)
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

  @doc """
  Defines a nonbinary constraint. Internally all nonbinary constraints are
  converted using a hidden variable translation. The end result is an
  additional variable, and 1 constraint added to the constraint graph. This
  implementation avoids the traditional N + 1 additional constraints by
  preforming a direct assignment of substituted variables during the evaluation
  """
  @spec post(t, [variable], constraint) :: t
  def post(problem, v, c) when is_list(v) do
    new_variable = new_hidden(v)

    ^problem = add_variable(problem, new_variable, :hidden)

    new_constraint = &apply(c, (for v_i <- v, do: &1[v_i]))

    post(problem, new_variable, new_constraint)
  end

  @doc """
  Defines a unary constraint on a variable.
  """
  @spec post(t, variable, constraint) :: t
  def post(problem, v, c),
    do: post(problem, v, v, c)

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

  @doc """
  Return a list of variables along with their domains
  """
  @spec labeled_variables(t, [{atom, any}]) :: [{variable, domain}]
  def labeled_variables(p, opts \\ []) do
    variables(p, opts)
    |> Enum.map(&variable(p, &1))
  end

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

  @doc "Returns the number of variables in the constraint graph"
  def no_variables(csp(graph: g)),
    do: :digraph.no_vertices(g)

  @doc "Returns the number of constraints in the constraint graph"
  def no_constraints(csp(graph: g)),
    do: :digraph.no_edges(g)

  defp new_hidden(variables),
    do: hidden(id: System.unique_integer, variables: variables)
end
