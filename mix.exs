defmodule PackageDelivery.Mixfile do
  use Mix.Project

  def project do
    [app: :package_delivery,
     version: "0.0.1",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger, :poolboy],
     mod: {PackageDelivery, []}]
  end

  defp deps do
    [
      {:poolboy, "~> 1.5.1"},
    ]
  end
end
