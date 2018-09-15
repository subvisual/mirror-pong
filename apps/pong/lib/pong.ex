defmodule Pong do
  use GenServer

  alias Pong.Game

  import Pong.Config, only: [config: 3]

  @fps 60

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def join do
    GenServer.call(__MODULE__, :join)
  end

  def leave(player_id) do
    GenServer.call(__MODULE__, {:leave, player_id})
  end

  def game_state do
    GenServer.call(__MODULE__, :game_state)
  end

  def subscribe(fun) when is_function(fun, 1) do
    GenServer.cast(__MODULE__, {:subscribe, fun})
  end

  def move(player, direction) do
    GenServer.cast(__MODULE__, {:move, player, direction})
  end

  def init(:ok) do
    state = %{
      game: Game.new(),
      fps: config(Pong, :fps, @fps),
      player_left: nil,
      player_right: nil,
      subscriptions: []
    }

    {:ok, state}
  end

  def handle_cast({:move, player, direction}, %{game: game} = state) do
    updated_game = Game.move(game, player, direction)
    new_state = %{state | game: updated_game}

    broadcast(new_state)

    {:noreply, new_state}
  end

  def handle_cast({:subscribe, sub}, %{subscriptions: subscriptions} = state) do
    {:noreply, %{state | subscriptions: [sub | subscriptions]}}
  end

  def handle_call(:join, _from, state) do
    case add_player(state) do
      {:error, :game_full} = error ->
        {:reply, error, state}

      {:ok, player_id, new_state} ->
        {:reply, {:ok, player_id}, new_state}
    end
  end

  def handle_call({:leave, player_id}, _from, state) do
    {:reply, :ok, remove_player(player_id, state)}
  end

  def handle_call(:game_state, _from, state) do
    {:reply, state.game, state}
  end

  defp add_player(%{player_left: nil} = state),
    do: {:ok, :left, %{state | player_left: true}}

  defp add_player(%{player_right: nil} = state),
    do: {:ok, :right, %{state | player_right: true}}

  defp add_player(_), do: {:error, :game_full}

  defp remove_player(:left, state), do: %{state | player_left: nil}
  defp remove_player(:right, state), do: %{state | player_right: nil}
  defp remove_player(_, state), do: state

  defp broadcast(%{subscriptions: subscriptions, game: game}) do
    for sub <- subscriptions do
      sub.(game)
    end
  end
end
