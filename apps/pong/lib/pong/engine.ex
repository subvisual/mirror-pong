defmodule Pong.Engine do
  use GenServer

  alias Pong.{
    Game,
    Movement,
    Renderer
  }

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

  def stop do
    GenServer.call(__MODULE__, :stop)
  end

  def state do
    GenServer.call(__MODULE__, :state)
  end

  def move(player, direction) do
    GenServer.cast(__MODULE__, {:move, player, direction})
  end

  def init(:ok) do
    state = default_state()

    {:ok, state}
  end

  def handle_cast({:move, player, direction}, %{game: game} = state) do
    updated_game = Game.move(game, player, direction)
    new_state = %{state | game: updated_game}

    {:noreply, new_state}
  end

  def handle_call(:join, _from, state) do
    case add_player(state) do
      {:ok, player_data, new_state} ->
        if players_ready?(new_state), do: start_game(state)

        {:reply, {:ok, player_data}, new_state}

      {:error, :game_full} = error ->
        {:reply, error, state}
    end
  end

  def handle_call({:leave, player_id}, _from, state) do
    wait_for_next_cycle(state.period + 100)

    {:reply, :ok, remove_player(player_id, state)}
  end

  def handle_call(:state, _from, state) do
    game_state = %{
      game: state.game,
      players: %{left: state.player_left, right: state.player_right}
    }

    {:reply, game_state, state}
  end

  def handle_call(:stop, _from, _state) do
    Renderer.stop()
    new_state = default_state()

    {:reply, new_state.game, new_state}
  end

  def handle_info(:work, %{game: game} = state) do
    new_state = %{state | game: Movement.apply_to(game)}

    schedule_work(new_state.period)

    {:noreply, new_state}
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

  defp players_ready?(state), do: state.player_left && state.player_right

  defp start_game(state) do
    Renderer.start()
    schedule_work(state.period)
  end

  defp default_state do
    fps = config(Pong, :fps, @fps)

    %{
      game: Game.new(),
      fps: fps,
      period: Kernel.trunc(1 / fps * 1_000),
      player_left: nil,
      player_right: nil
    }
  end

  defp wait_for_next_cycle(timeout) do
    receive do
      :work ->
        :ok
    after
      timeout ->
        :ok
    end
  end

  defp schedule_work(period) do
    Process.send_after(self(), :work, period)
  end
end
