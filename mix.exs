defmodule Archytax.Mixfile do
  use Mix.Project

  def project do
    [app: :archytax,
     version: "0.1.2",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     deps: deps(),
     # ExDoc Documentation
     name: "Archytax",
     source_url: "https://github.com/hanselmw/archytax",
     docs: [
            main: "Archytax",
            extras: ["README.md"]
           ]
     ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
    [applications: [:nerves_uart]]
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
    [
    {:nerves_uart, "~> 0.1.1"},
    {:ex_doc, "~> 0.14", only: :dev, runtime: false}
    ]
  end

  defp description() do
    """
    An implementation of the Firmata protocol for elixir.
    """
  end

  defp package() do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE.txt"],
      maintainers: ["vicvans20, hanselmw"],
      licenses: ["GPL"],
      links: %{
        "GitHub" => "https://github.com/hanselmw/archytax",
        "Firmata Protocol" => "https://github.com/firmata/protocol"
      }
    ]
  end
end
