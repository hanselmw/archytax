defmodule Archytax.Mixfile do
  use Mix.Project

  def project do
    [app: :archytax,
     version: "0.0.1",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description,
     package: package,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

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
    []
  end
  
  defp description do
    """
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE.txt"],
      maintainers: ["Keyvan Fatehi"],
      licenses: ["GPL"],
      links: %{
        "GitHub" => "https://github.com/hanselmw/archytax",
        "Firmata Protocol" => "https://github.com/firmata/protocol"
      }
    ]
  end
end
