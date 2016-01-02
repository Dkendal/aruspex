defmodule Aruspex.Mixfile do
  use Mix.Project

  def project do
    [
      app: :aruspex,
      version: "0.0.1",
      elixir: "~> 1.2",
      description: description,
      package: package,
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      elixirc_paths: elixirc_paths(Mix.env),
      deps: deps
    ]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [
      applications: applications(Mix.env)
    ]
  end

  def applications(_all) do
    [:logger]
  end

  def description do
    """
    A configurable constraint solver with an API based on JSR 331.
    """
  end

  def package do
    [
      links: %{
        "Github" => "https://www.github.com/dkendal/aruspex"
      },
      maintainers: ["dylankendal@gmail.com"],
      licenses: ["MIT"]
    ]
  end

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp deps do
    [
      {:dialyze, "~> 0.2", only: :dev},
      {:ex_doc, "~> 0.10", only: :docs},
      {:ex_spec, github: "dkendal/ex_spec", branch: "master", only: :test},
      {:zipper_tree, "~> 0.1"},
      {:exyz, "~> 1.0.0"},
      {:eflame,
        github: "proger/eflame", compile: "~/.mix/rebar compile", only: :dev}
    ]
  end
end
