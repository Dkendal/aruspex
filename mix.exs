defmodule Aruspex.Mixfile do
  use Mix.Project

  def project do
    [
      app: :aruspex,
      version: "0.0.1",
      elixir: "~> 1.0",
      description: description,
      package: package,
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps,
    ]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :dbg]]
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

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:dbg, github: "fishcakez/dbg"},
      {:dialyze, "~> 0.2", only: :dev},
      {:ex_doc, "~> 0.10", only: :docs},
      {:ex_spec, github: "dkendal/ex_spec", branch: "master", only: :test},
      {:exactor, "~> 2.2"},
      {:exyz, "~> 1.0.0"},
      {:pattern_tap, []}
    ]
  end
end
