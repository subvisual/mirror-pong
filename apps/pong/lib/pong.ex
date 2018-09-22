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

  def restart do
    GenServer.call(__MODULE__, :restart)
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
    {:ok, default_state()}
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

      {:ok, player_data, new_state} ->
        {:reply, {:ok, player_data}, new_state}
    end
  end

  def handle_call({:leave, player_id}, _from, state) do
    {:reply, :ok, remove_player(player_id, state)}
  end

  def handle_call(:game_state, _from, state) do
    {:reply, state.game, state}
  end

  def handle_call(:restart, _from, state) do
    new_state = %{default_state() | subscriptions: state.subscriptions}

    broadcast(new_state)

    {:reply, new_state.game, new_state}
  end

  defp add_player(%{player_left: nil} = state) do
    player_data = %{
      player_id: :left,
      paddle_color: state.game.paddle_left.fill
    }

    {:ok, player_data, %{state | player_left: true}}
  end

  defp add_player(%{player_right: nil} = state) do
    player_data = %{
      player_id: :right,
      paddle_color: state.game.paddle_right.fill
    }

    {:ok, player_data, %{state | player_right: true}}
  end

  defp add_player(_), do: {:error, :game_full}

  defp remove_player(:left, state), do: %{state | player_left: nil}
  defp remove_player(:right, state), do: %{state | player_right: nil}
  defp remove_player(_, state), do: state

  defp broadcast(%{subscriptions: subscriptions, game: game}) do
    for sub <- subscriptions do
      sub.(game)
    end
  end

  defp default_state do
    %{
      game: Game.new(),
      fps: config(Pong, :fps, @fps),
      player_left: nil,
      player_right: nil,
      subscriptions: []
    }
  end
end
