defmodule FaktoryWorker.MixProject do
  use Mix.Project

  def project do
    [
      app: :faktory_worker,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:mox, "~> 0.5", only: :test}
    ]
  end
end
