defmodule Pong.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Pong.Server
    ]

    opts = [strategy: :one_for_one, name: Pong.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
