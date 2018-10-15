defmodule Pong.Engine do
  alias Pong.{
    Game,
    Movement,
    Renderer
  }

  @type state :: %{
          game: Game.t(),
          fps: integer(),
          period: float(),
          start_delay: state(),
          player_left: any(),
          player_right: any(),
          movements: Movement.Buffer.t(),
          events: list()
        }

  @callback add_player(left :: any(), right :: any()) ::
              {:ok, Game.player_ref(), any()} | {:error, :game_full}

  @callback remove_player(player_id :: Game.player_ref(), player :: any()) ::
              {any(), any()} | {:error, :invalid_player}

  @callback players_ready?(left :: any(), right :: any()) :: boolean()

  defmacro __using__(_) do
    quote do
      use GenServer

      import Pong.Config, only: [config: 3]

      @behaviour Pong.Engine

      @module unquote(__MODULE__)

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

      def handle_cast(
            {:move, player, direction},
            %{movements: movements} = state
          ) do
        updated_movements = Movement.Buffer.add(movements, player, direction)
        new_state = %{state | movements: updated_movements}

        {:noreply, new_state}
      end

      def handle_call(:join, _from, state) do
        wait_for_next_cycle(state.period + 100)

        case add_player(state.player_left, state.player_right) do
          {:ok, player_id, value} ->
            {player_data, new_state} = add_player_to(state, player_id, value)

            {:reply, {:ok, player_data}, new_state}

          {:error, :game_full} = error ->
            {:reply, error, state}
        end
      end

      def handle_call({:leave, player_id}, _from, state) do
        wait_for_next_cycle(state.period + 100)

        new_state = remove_player_from(state, player_id)

        unless players_ready?(new_state.player_left, new_state.player_right),
          do: Renderer.stop()

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

      defp add_player_to(state, player_id, value) do
        player_ref = String.to_existing_atom("player_#{player_id}")
        paddle_ref = String.to_existing_atom("paddle_#{player_id}")

        new_state =
          state
          |> Map.put(player_ref, value)
          |> prepare_start()

        player_data = %{
          player_id: player_id,
          paddle_color: Map.get(new_state.game, paddle_ref).fill
        }

        {player_data, new_state}
      end

      defp remove_player_from(state, player_id) do
        player_ref = String.to_existing_atom("player_#{player_id}")
        player = Map.get(state, player_ref)

        case remove_player(player_id, player) do
          {:error, :invalid_player} ->
            state

          {:ok, new_player} ->
            state
            |> Map.put(player_ref, new_player)
            |> push_event({"player_left", %{player: player_id}})
        end
      end

      defp player_scored?(events), do: find_event(events, "player_scored")

      defp game_over?(events), do: find_event(events, "game_over")

      defp find_event(events, event),
        do: Enum.find(events, false, fn {e, _} -> event == e end)

      defp prepare_start(state) do
        %{
          game: game,
          player_left: player_left,
          player_right: player_right,
          in_progress: in_progress,
          start_delay: start_delay,
          period: period
        } = state

        cond do
          in_progress ->
            schedule_work(period)
            state

          players_ready?(player_left, player_right) ->
            Renderer.start(game, start_delay)
            schedule_work(start_delay)
            %{state | in_progress: true}

          true ->
            state
        end
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
          in_progress: false,
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
  end
end
