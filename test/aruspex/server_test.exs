defmodule Aruspex.ServerTest do
  use Aruspex.Case
  import Aruspex.Server

  setup do
    {:ok, pid} = start_link

    on_exit fn ->
      Aruspex.Server.stop pid
    end

    {:ok, problem: pid}
  end

  describe "variable/3" do
    it "defines a new variable", config do
      domain =
        config.problem
        |> variable(:y, 1..10)
        |> :sys.get_state
        |> Aruspex.State.get_var(:y)
        |> Aruspex.Var.domain
      assert domain == 1..10
    end
  end
end
