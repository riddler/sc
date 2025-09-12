defmodule SC.MixProject do
  use Mix.Project

  @app :sc
  @version "1.0.2"
  @description "[DEPRECATED] Use 'statifier' package instead: https://github.com/riddler/statifier"
  @source_url "https://github.com/riddler/sc"
  @deps []

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.17",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: @deps,
      docs: docs(),
      description: @description,
      package: package(),
      deprecated: [
        reason: "Package renamed to 'statifier'. Use {:statifier, \"~> 1.9\"} instead.",
        replacement: :statifier
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      name: @app,
      files: ~w(lib mix.exs README.md LICENSE CHANGELOG.md),
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
      maintainers: ["Riddler Team"]
    ]
  end

  defp docs do
    [
      name: "SC",
      source_ref: "v#{@version}",
      canonical: "https://hexdocs.pm/sc",
      source_url: @source_url,
      extras: ["README.md", "LICENSE"],
      main: "readme"
    ]
  end

  defp elixirc_paths(:test), do: ["test/support", "lib"]
  defp elixirc_paths(_), do: ["lib"]
end
