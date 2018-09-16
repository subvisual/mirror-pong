defmodule Pong.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: Pong.Supervisor]
    Supervisor.start_link(children(Mix.env()), opts)
  end

  defp children(:test), do: []
  defp children(_), do: [Pong]
end
