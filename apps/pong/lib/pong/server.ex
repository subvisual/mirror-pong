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

  def join(player_name) do
    GenServer.call(__MODULE__, {:join, player_name})
  end

  def init(opts) do
    state = %{game: Pong.Game.new(opts)}

    {:ok, state}
  end

  def handle_call({:join, player_name}, _from, state) do
    {reply, new_state} =
      case add_player(player_name, state) do
        {:error, :game_full} = error -> {error, state}
        {:ok, _updated_state} = reply -> reply
      end

    {:reply, reply, new_state}
  end

  defp add_player(name, %{player_left: nil} = state),
    do: {:ok, %{state | player_left: name}}

  defp add_player(name, %{player_right: nil} = state),
    do: {:ok, %{state | player_right: name}}

  defp add_player(_, _),
    do: {:error, :game_full}

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
