defmodule MirrorPong.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      deps_path: deps_path(),
      build_path: build_path(),
      dialyzer: [
        plt_add_deps: :transitive,
        plt_add_apps: [:mix],
        flags: [:underspecs, :race_conditions]
      ]
    ]
  end

  # Dependencies listed here are available only for this
  # project and cannot be accessed from applications inside
  # the apps folder.
  #
  # Run "mix help deps" for examples and options.
  defp deps do
    [
      {:credo, "~> 0.10.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.3", only: [:dev], runtime: false}
    ]
  end

  # CI caching issues should definitely not be part of the mix config.
  # However there is an issue with rebar and symlinks which causes cowboy to
  # crash when compiling.  See: https://github.com/erlang/rebar3/issues/1708
  defp deps_path, do: System.get_env("DEPS_PATH") || "deps"
  defp build_path, do: System.get_env("BUILD_PATH") || "_build"
end
