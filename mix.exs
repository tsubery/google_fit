defmodule GoogleFit.Mixfile do
  use Mix.Project

  def project do
    [app: :google_fit,
     version: "0.1.0",
     elixir: "~> 1.4.0-rc.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  # def application do
  #   [extra_applications: [:logger]]
  # end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:oauth2, "~> 0.8"},
      {:poison, "~> 3.0"},
      {:dialyxir, "~> 0.4", only: [:dev], runtime: false}
    ]
  end
end
