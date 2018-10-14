defmodule Pong.Engine do
  use GenServer

  alias Pong.{
    Game,
    Movement,
    Renderer
  }

  import Pong.Config, only: [config: 3]

  @fps 60
  @start_delay 3_000

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

  def consume do
    GenServer.call(__MODULE__, :consume)
  end

  def move(player, direction) do
    GenServer.cast(__MODULE__, {:move, player, direction})
  end

  def init(:ok) do
    state = default_state()

    {:ok, state}
  end

  def handle_cast({:move, player, direction}, %{movements: movements} = state) do
    updated_movements = Movement.Buffer.add(movements, player, direction)
    new_state = %{state | movements: updated_movements}

    {:noreply, new_state}
  end

  def handle_call(:join, _from, state) do
    wait_for_next_cycle(state.period + 100)

    case add_player(state) do
      {:ok, player_data, new_state} ->
        if players_ready?(new_state), do: prepare_start(state)

        {:reply, {:ok, player_data}, new_state}

      {:error, :game_full} = error ->
        {:reply, error, state}
    end
  end

  def handle_call({:leave, player_id}, _from, state) do
    wait_for_next_cycle(state.period + 100)

    Renderer.stop()

    new_state =
      state
      |> remove_player(player_id)
      |> push_event({"player_left", %{player: player_id}})

    {:reply, :ok, new_state}
  end

  def handle_call(:consume, _from, state) do
    reply = {state.game, state.events}
    new_state = %{state | events: []}

    {:reply, reply, new_state}
  end

  def handle_call(:stop, _from, _state) do
    Renderer.stop()
    new_state = default_state()

    {:reply, new_state.game, new_state}
  end

  def handle_info(:work, %{game: game, movements: movements} = state) do
    {events, updated_game} = Movement.apply_to(game, movements)

    new_state =
      %{
        state
        | game: updated_game,
          movements: Movement.Buffer.new(),
          events: events ++ state.events
      }
      |> handle_events()

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

  defp remove_player(state, :left), do: %{state | player_left: nil}
  defp remove_player(state, :right), do: %{state | player_right: nil}
  defp remove_player(state, _), do: state

  defp players_ready?(state), do: state.player_left && state.player_right

  defp handle_events(%{events: events} = state) do
    cond do
      game_over?(events) ->
        default_state(events: events)

      player_scored?(events) ->
        schedule_work(state.start_delay)
        state

      true ->
        schedule_work(state.period)
        state
    end
  end

  defp player_scored?(events), do: find_event(events, "player_scored")

  defp game_over?(events), do: find_event(events, "game_over")

  defp find_event(events, event) do
    Enum.find(events, false, fn {e, _} -> event == e end)
  end

  defp prepare_start(%{game: game, start_delay: start_delay}) do
    Renderer.start(game, start_delay)

    schedule_work(start_delay)
  end

  defp push_event(%{events: events} = state, event) do
    %{state | events: events ++ [event]}
  end

  defp default_state(overrides \\ []) do
    fps = config(Pong, :fps, @fps)
    start_delay = config(Pong, :start_delay, @start_delay)

    [
      game: Game.new(),
      fps: fps,
      period: Kernel.trunc(1 / fps * 1_000),
      start_delay: start_delay,
      player_left: nil,
      player_right: nil,
      movements: Movement.Buffer.new(),
      events: []
    ]
    |> Keyword.merge(overrides)
    |> Enum.into(%{})
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
