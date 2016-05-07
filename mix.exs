defmodule Formless.Mixfile do
  use Mix.Project

  def project do
    [app: :formless,
     version: "0.0.1",
     elixir: "~> 1.2",
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [
      applications: [:logger, :cowboy, :plug, :neo4j_sips, :exleveldb, :poolboy],
      mod: {Formless, []}
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
      {:neo4j_sips, "~> 0.1"},
      {:poison, "~> 2.0"},
      {:exleveldb, "~> 0.6"},
      {:eleveldb, "~> 2.1.0"},
      {:cowboy, "~> 1.0.0"},
      {:plug, "~> 1.0"},
      {:exrm, "~> 1.0"}
    ]
  end
end
