defmodule CaveaticaController.MixProject do
  use Mix.Project

  def project do
    [
      app: :caveatica_controller,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      mod: {CaveaticaController.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:ex_cldr_dates_times, ">= 0.0.0"},
      {:finch, ">= 0.0.0"},
      {:gettext, ">= 0.0.0"},
      {:jason, ">= 0.0.0"},
      {:plug_cowboy, ">= 0.0.0"},
      {:phoenix, ">= 0.0.0"},
      {:phoenix_html, ">= 0.0.0"},
      {:phoenix_live_reload, ">= 0.0.0", only: :dev},
      {:phoenix_live_view, ">= 0.0.0"},
      {:tzdata, ">= 0.0.0"},
      # Scheduled tasks
      {:astro, ">= 0.0.0"},
      {:quantum, ">= 0.0.0"},
      # Assets
      {:esbuild, ">= 0.0.0", runtime: Mix.env() == :dev},
      {:tailwind, ">= 0.0.0", runtime: Mix.env() == :dev}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "assets.setup", "assets.build"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind default", "esbuild default"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"]
    ]
  end
end
