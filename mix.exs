defmodule Construct.Inherit.MixProject do
  use Mix.Project

  def project do
    [
      app: :construct_inherit,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Hex
      description: description(),
      package: package(),

      # Docs
      name: "Construct.Inherit",
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: []
    ]
  end

  defp deps do
    [
      {:construct, "~> 2.0"},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:benchfella, "~> 0.3.5", only: :dev},
    ]
  end

  defp description do
    "Inheritance for Construct"
  end

  defp package do
    [
      name: :construct_inherit,
      maintainers: ["Yuri Artemev"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/ExpressApp/construct_inherit"}
    ]
  end

  defp docs do
    [
      main: "readme",
      source_url: "https://github.com/ExpressApp/construct_inherit",
      extras: ["README.md"]
    ]
  end
end
