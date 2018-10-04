defmodule Pong.Renderer do
  use GenServer

  import Pong.Config, only: [config: 3]

  @fps 60

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def subscribe(fun) when is_function(fun, 1) do
    GenServer.cast(__MODULE__, {:subscribe, fun})
  end

  def start do
    GenServer.cast(__MODULE__, :start)
  end

  def stop do
    GenServer.cast(__MODULE__, :stop)
  end

  def init(:ok) do
    {:ok, default_state()}
  end

  def handle_cast({:subscribe, sub}, %{subscriptions: subscriptions} = state) do
    {:noreply, %{state | subscriptions: [sub | subscriptions]}}
  end

  def handle_cast(:start, state) do
    schedule_work(state.period)

    {:noreply, state}
  end

  def handle_cast(:stop, state) do
    wait_for_next_render(state.period + 100)

    {:noreply, state}
  end

  def handle_info(:work, state) do
    game_state = Pong.Engine.state()
    broadcast(state.subscriptions, game_state)

    schedule_work(state.period)

    {:noreply, state}
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
      subscriptions: []
    }
  end

  defp schedule_work(period) do
    Process.send_after(self(), :work, period)
  end
end
