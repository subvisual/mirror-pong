defmodule Pong.EngineTest do
  use ExUnit.Case
  doctest Pong.Engine

  alias Pong.{
    Engines,
    Movement,
    Renderer
  }

  alias Pong.TestEngine, as: Engine

  import Pong.Factory
  import Mock

  describe "init/1" do
    test "creates the correct state" do
      {:ok, state} = Engine.init(:ok)

      assert %{
               game: _,
               fps: _,
               period: _,
               start_delay: _,
               player_left: nil,
               player_right: nil,
               in_progress: false,
               movements: _
             } = state
    end
  end

  describe "handle_cast/2 for :move messages" do
    test "returns the state with an updated movements buffer" do
      state = build_pong_state()

      {:noreply, %{movements: movements}} =
        Engine.handle_cast({:move, :left, :up}, state)

      assert movements.left == %{up: 1, down: 0}
    end
  end

  describe "handle_call/3 for :join messages" do
    test "starts the renderer" do
      with_mock Renderer, start: fn _, _ -> :ok end do
        state = build_pong_state(player_left: 1)

        {:reply, _, _} = Engine.handle_call(:join, self(), state)

        assert called(Renderer.start(state.game, state.start_delay))
      end
    end

    test "schedules work if all players are ready" do
      with_mock Renderer, start: fn _, _ -> :ok end do
        state = build_pong_state(player_left: 1, period: 1, start_delay: 1)

        {:reply, _, _} = Engine.handle_call(:join, self(), state)

        assert_receive :work, 100
      end
    end

    test "doesn't schedule work when a player is missing" do
      state = build_pong_state(period: 1, start_delay: 1)

      {:reply, _, _} = Engine.handle_call(:join, self(), state)

      refute_receive :start, 100
    end

    test "returns the player data" do
      state = build_pong_state()

      {:reply, {:ok, player_data}, _} = Engine.handle_call(:join, self(), state)

      assert %{
               player_id: :left,
               paddle_color: _
             } = player_data
    end
  end

  describe "handle_call/3 for :leave messages" do
    # This test only happens in multi-like cases
    test "adds a player left event if a player leaves" do
      state = build_pong_state(player_right: 2, player_left: 2)

      assert {:reply, :ok, new_state} =
               Engines.Multi.handle_call({:leave, :right}, self(), state)

      assert new_state.events == [
               {"player_left", %{player_left: 2, player_right: 1}}
             ]
    end

    test "ends the game if there aren't enough players" do
      state = build_pong_state(player_right: 1, player_left: 1)

      assert {:reply, :ok, new_state} =
               Engine.handle_call({:leave, :right}, self(), state)

      assert [{"game_over", _}] = new_state.events
    end

    test "waits for the pending cycle" do
      # This is a pretty complicated test to do. The way I achieved it was by
      # spawning a process that would block on the handle cast for a long time
      # and send a message before that. We can then assert that it blocked by
      # refuting having received before the period had passed and asserting to
      # have received after it did. We can take this test further by spawning
      # the same process again but sending the :work message immediately and
      # asserting that it replied back
      state = build_pong_state(player_right: 1, period: 200)
      pid = self()

      spawn fn ->
        Engine.handle_call({:leave, :right}, self(), state)

        send pid, :checkpoint_1
      end

      refute_receive :checkpoint_1, 100
      assert_receive :checkpoint_1, 400

      child_pid =
        spawn fn ->
          Engine.handle_call({:leave, :right}, self(), state)

          send pid, :checkpoint_2
        end

      send child_pid, :work

      assert_receive :checkpoint_2, 100
    end
  end

  describe "handle_call/3 for :consume messages" do
    test "returns the game state and any pending events" do
      state = build_pong_state(events: [{"one", "event"}])
      reset_state = %{state | events: []}

      assert {:reply, {state.game, [{"one", "event"}]}, reset_state} ==
               Engine.handle_call(:consume, self(), state)
    end
  end

  describe "handle_call/3 for :stop messages" do
    test "resets the state" do
      with_mock Renderer, stop: fn -> :ok end do
        state =
          build_pong_state(
            player_left: 1,
            player_right: 1
          )

        {:reply, _, new_state} = Engine.handle_call(:stop, self(), state)

        assert %{
                 game: _,
                 fps: _,
                 player_left: nil,
                 player_right: nil
               } = new_state
      end
    end

    test "stops the renderer" do
      with_mock Renderer, stop: fn -> :ok end do
        state =
          build_pong_state(
            player_left: 1,
            player_right: 1
          )

        {:reply, _, _} = Engine.handle_call(:stop, self(), state)

        assert called(Renderer.stop())
      end
    end
  end

  describe "handle_info/2 for :work messages" do
    test "schedules a new work cycle" do
      state = build_pong_state(period: 1)

      {:noreply, _} = Engine.handle_info(:work, state)

      assert_receive :work, 100
    end

    test "applies the movements to the game" do
      with_mock Movement, apply_to: fn _, _ -> {[], :ok} end do
        state = build_pong_state(player_left: 1, player_right: 1)

        {:noreply, _} = Engine.handle_info(:work, state)

        assert called(Movement.apply_to(state.game, state.movements))
      end
    end

    test "resets the movement buffer" do
      with_mock Movement, apply_to: fn _, _ -> {[], :ok} end do
        state = build_pong_state(player_left: 1, player_right: 1)

        {:noreply, new_state} = Engine.handle_info(:work, state)

        assert new_state.movements == Movement.Buffer.new()
      end
    end

    test "updates the game events" do
      mock_apply_to = fn game, _ -> {[{"a new", "event"}], game} end

      with_mock Movement, apply_to: mock_apply_to do
        state = build_pong_state(player_left: 1, player_right: 1)

        {:noreply, new_state} = Engine.handle_info(:work, state)

        assert new_state.events == [{"a new", "event"}]
      end
    end

    test "uses the start delay if there was a point scored" do
      mock_apply_to = fn game, _ -> {[{"player_scored", %{}}], game} end

      with_mock Movement, apply_to: mock_apply_to do
        state =
          build_pong_state(
            player_left: 1,
            player_right: 1,
            start_delay: 1,
            period: 1_000
          )

        {:noreply, _} = Engine.handle_info(:work, state)

        assert_receive :work
      end
    end

    test "resets the state but keeps the events if the game has ended" do
      mock_apply_to = fn game, _ -> {[{"game_over", %{}}], game} end

      with_mock Movement, apply_to: mock_apply_to do
        state =
          build_pong_state(
            player_left: 1,
            player_right: 1,
            start_delay: 1,
            period: 1
          )

        {:noreply, new_state} = Engine.handle_info(:work, state)

        assert new_state.events == [{"game_over", %{}}]
        refute new_state.player_left
        refute new_state.player_right
      end
    end

    test "doesn't schedule work if the game has ended" do
      mock_apply_to = fn game, _ -> {[{"game_over", %{}}], game} end

      with_mock Movement, apply_to: mock_apply_to do
        state =
          build_pong_state(
            player_left: 1,
            player_right: 1,
            start_delay: 1,
            period: 1
          )

        {:noreply, _} = Engine.handle_info(:work, state)

        refute_receive :work
      end
    end
  end

  defp build_pong_state(overrides \\ []) do
    [
      game: build(:game),
      fps: 60,
      period: Kernel.trunc(1 / 60 * 1_000),
      start_delay: 100,
      player_left: nil,
      player_right: nil,
      movements: Movement.Buffer.new(),
      in_progress: false,
      events: []
    ]
    |> Keyword.merge(overrides)
    |> Enum.into(%{})
  end
end
