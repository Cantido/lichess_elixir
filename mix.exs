defmodule LichessElixir.MixProject do
  use Mix.Project

  def project do
    [
      app: :lichess_elixir,
      description: "A Lichess library for Elixir",
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      source_url: "https://github.com/Cantido/lichess_elixir",
      deps: deps(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/Cantido/lichess_elixir",
        "Sponsor" => "https://liberapay.com/rosa"
      }
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.28", only: :dev, runtime: false},
      {:httpoison, "~> 1.8"},
      {:jason, "~> 1.3"}
    ]
  end
end
