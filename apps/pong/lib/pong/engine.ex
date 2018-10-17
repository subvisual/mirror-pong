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
          left: any(),
          right: any(),
          movements: Movement.Buffer.t(),
          events: list()
        }

  @callback add_player(left :: any(), right :: any(), id :: any()) ::
              {:ok, Game.player_ref(), any()} | {:error, :game_full}

  @callback remove_player(player_id :: any(), player :: any()) ::
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

      def leave({player_id, player_side}) do
        GenServer.call(__MODULE__, {:leave, player_id, player_side})
      end

      def stop do
        GenServer.call(__MODULE__, :stop)
      end

      def consume do
        GenServer.call(__MODULE__, :consume)
      end

      def move(side, direction) do
        GenServer.cast(__MODULE__, {:move, side, direction})
      end

      def init(:ok) do
        state = default_state()

        {:ok, state}
      end

      def handle_cast(
            {:move, side, direction},
            %{movements: movements} = state
          ) do
        updated_movements = Movement.Buffer.add(movements, side, direction)
        new_state = %{state | movements: updated_movements}

        {:noreply, new_state}
      end

      def handle_call(:join, _from, state) do
        id = UUID.uuid4()

        case add_player(state.left, state.right, id) do
          {:ok, side, value} ->
            {player_data, new_state} = add_player_to(state, id, side, value)

            {:reply, {:ok, player_data}, new_state}

          {:error, :game_full} = error ->
            {:reply, error, state}
        end
      end

      def handle_call({:leave, player_id, player_side}, _from, state) do
        new_state =
          case remove_player_from(state, player_id, player_side) do
            {:ok, state_without_player} ->
              end_game_if_over(state_without_player)

            {:error, :invalid_player} ->
              state
          end

        {:reply, :ok, new_state}
      end

      def handle_call(:consume, _from, state) do
        reply = {state.game, state.events}

        {:reply, reply, %{state | events: []}}
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

      defp add_player_to(state, id, side, value) do
        paddle_ref = String.to_existing_atom("paddle_#{side}")
        paddle_color = Map.get(state.game, paddle_ref).fill

        new_state =
          state
          |> Map.put(side, value)
          |> prepare_start()

        player_data = %{
          player_id: id,
          player_side: side,
          paddle_color: paddle_color
        }

        {player_data, new_state}
      end

      defp remove_player_from(state, id, side) do
        side_value = Map.get(state, side)

        case remove_player(id, side_value) do
          {:error, :invalid_player} = error ->
            error

          {:ok, new_value} ->
            new_state = Map.put(state, side, new_value)

            {:ok,
             push_event(
               new_state,
               {"player_left",
                %{
                  player_left: new_state.left,
                  player_right: new_state.right
                }}
             )}
        end
      end

      defp end_game_if_over(state) do
        if players_ready?(state.left, state.right) do
          state
        else
          wait_for_next_cycle(state.period + 100)

          push_event(
            default_state(),
            {"game_over", state.game}
          )
        end
      end

      defp player_scored?(events), do: find_event(events, "player_scored")

      defp game_over?(events), do: find_event(events, "game_over")

      defp find_event(events, event),
        do: Enum.find(events, false, fn {e, _} -> event == e end)

      defp prepare_start(state) do
        %{
          game: game,
          left: left,
          right: right,
          in_progress: in_progress,
          start_delay: start_delay,
          period: period
        } = state

        cond do
          in_progress ->
            state

          players_ready?(left, right) ->
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
          left: nil,
          right: nil,
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
