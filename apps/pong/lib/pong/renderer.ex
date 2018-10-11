defmodule Pong.Renderer do
  use GenServer

  alias Pong.Game

  import Pong.Config, only: [config: 3]

  @fps 60

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def subscribe(fun) when is_function(fun, 1) do
    GenServer.cast(__MODULE__, {:subscribe, fun})
  end

  def start(%Game{} = game, delay) do
    GenServer.cast(__MODULE__, {:start, game, delay})
  end

  def stop do
    GenServer.cast(__MODULE__, :stop)
  end

  def current_state do
    GenServer.call(__MODULE__, :current_state)
  end

  def init(:ok) do
    {:ok, default_state()}
  end

  def handle_cast({:subscribe, sub}, %{subscriptions: subscriptions} = state) do
    {:noreply, %{state | subscriptions: [sub | subscriptions]}}
  end

  def handle_cast({:start, game, delay}, state) do
    wait_for_next_render(state.period + 100)

    broadcast(
      state.subscriptions,
      {"game_starting", %{"delay" => delay, "game" => game}}
    )

    schedule_work(delay)

    {:noreply, state}
  end

  def handle_cast(:stop, state) do
    wait_for_next_render(state.period + 100)

    {:noreply, %{state | game: nil}}
  end

  def handle_call(:current_state, _from, state) do
    reply =
      case state.game do
        nil -> {:error, :not_started}
        game -> {:ok, game}
      end

    {:reply, reply, state}
  end

  def handle_info(:work, state) do
    {game, events} = Pong.Engine.consume()

    broadcast(state.subscriptions, {"data", game})
    for event <- events, do: broadcast(state.subscriptions, event)

    schedule_work(state.period)

    {:noreply, %{state | game: game}}
  end

  defp broadcast(subscriptions, game) do
    for sub <- subscriptions do
      sub.(game)
    end
  end

  defp wait_for_next_render(timeout) do
    receive do
      :work ->
        :ok
    after
      timeout ->
        :ok
    end
  end

  defp default_state do
    fps = config(Pong, :fps, @fps)

    %{
      fps: fps,
      period: Kernel.trunc(1 / fps * 1_000),
      subscriptions: [],
      game: nil
    }
  end

  defp schedule_work(period) do
    Process.send_after(self(), :work, period)
  end
end
