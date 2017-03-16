defmodule GoogleFit.Mixfile do
  use Mix.Project

  def project do
    [app: :google_fit,
     version: "0.2.3",
     elixir: ">= 1.4.0",
     description: "GoogleFit API wrapper",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     package: package()]
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
      {:dialyxir, "~> 0.4", only: [:dev], runtime: false},
      {:credo, "~> 0.5", only: [:dev, :test]},
      {:ex_doc, ">= 0.0.0", only: :dev},
    ]
  end

  defp package do
    [
     name: :google_fit,
     files: ["lib", "mix.exs", "README*", "LICENSE*"],
     maintainers: ["Gal Tsubery"],
     licenses: ["Apache 2.0"],
     links: %{"GitHub" => "https://github.com/tsubery/google_fit"}
   ]
  end
end
