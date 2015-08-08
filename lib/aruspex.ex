defmodule Aruspex do
  use GenServer

  def new(default\\[])

  def new(default) do
    GenServer.start_link(__MODULE__, default)
  end

  def variables(pid, variables) do
  end

  def domain(pid, variables, domain) do
  end

  def constraint(pid, variables, constraint) do
  end

  def label(pid) do
  end
end
