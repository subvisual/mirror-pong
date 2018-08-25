defmodule Pong.Server do
  use GenServer

  import Pong.Config, only: [config: 3]

  @fps 60
  @speed 50
  @paddle {50, 2}
  @board {500, 500}
  @ball 2

  def start_link(_) do
    GenServer.start_link(__MODULE__, game_opts(), name: __MODULE__)
  end

  def init(opts) do
    state = %{game: Pong.Game.new(opts)}

    {:ok, state}
  end

  defp game_opts do
    [
      fps: config(Pong, :fps, @fps),
      speed: config(Pong, :speed, @speed),
      paddle: config(Pong, :paddle_length, @paddle),
      board: config(Pong, :board, @board),
      ball: config(Pong, :ball, @ball)
    ]
  end
end
