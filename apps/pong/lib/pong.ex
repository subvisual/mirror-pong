defmodule Pong do
  use GenServer

  alias Pong.Game

  import Pong.Config, only: [config: 3]

  @fps 60

  def start(board_width, board_height) do
    opts = [
      fps: config(Pong, :fps, @fps),
      board_width: board_width,
      board_height: board_height
    ]

    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def join do
    GenServer.call(__MODULE__, :join)
  end

  def move(player, direction) do
    GenServer.cast(__MODULE__, {:move, player, direction})
  end

  def init(opts) do
    fps = Keyword.fetch!(opts, :fps)
    board_width = Keyword.fetch!(opts, :board_width)
    board_height = Keyword.fetch!(opts, :board_height)

    state = %{
      game: Game.new(board_width, board_height),
      fps: fps,
      player_left: nil,
      player_right: nil
    }

    {:ok, state}
  end

  def handle_cast({:move, player, direction}, %{game: game} = state) do
    updated_game = Game.move(game, player, direction)

    {:ok, %{state | game: updated_game}}
  end

  def handle_call(:join, _from, state) do
    case add_player(state) do
      {:error, :game_full} = error ->
        {:reply, error, state}

      {:ok, player_id, new_state} ->
        {:reply, {:ok, player_id}, new_state}
    end
  end

  defp add_player(%{player_left: nil} = state),
    do: {:ok, :left, %{state | player_left: true}}

  defp add_player(%{player_right: nil} = state),
    do: {:ok, :right, %{state | player_right: true}}

  defp add_player(_),
    do: {:error, :game_full}
end
