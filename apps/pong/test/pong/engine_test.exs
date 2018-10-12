defmodule Pong.EngineTest do
  use ExUnit.Case
  doctest Pong.Engine

  alias Pong.{
    Engine,
    Movement,
    Renderer
  }

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
    test "errors if the game is full" do
      state = build_pong_state(player_left: true, player_right: true)

      {:reply, error, _} = Engine.handle_call(:join, self(), state)

      assert {:error, :game_full} == error
    end

    test "adds the left player if no players have joined" do
      state = build_pong_state()

      {:reply, _, new_state} = Engine.handle_call(:join, self(), state)

      assert new_state[:player_left]
    end

    test "adds the right player if there is a left player" do
      with_mock Renderer, start: fn _, _ -> :ok end do
        state = build_pong_state(player_left: true)

        {:reply, _, new_state} = Engine.handle_call(:join, self(), state)

        assert new_state[:player_right]
      end
    end

    test "starts the renderer" do
      with_mock Renderer, start: fn _, _ -> :ok end do
        state = build_pong_state(player_left: true)

        {:reply, _, _} = Engine.handle_call(:join, self(), state)

        assert called(Renderer.start(state.game, state.start_delay))
      end
    end

    test "schedules work if all players are ready" do
      with_mock Renderer, start: fn _, _ -> :ok end do
        state = build_pong_state(player_left: true, period: 1, start_delay: 1)

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
    test "removes the correct player from the state" do
      state = build_pong_state(player_right: true)

      {:reply, :ok, new_state} =
        Engine.handle_call({:leave, :right}, self(), state)

      refute new_state[:player_right]
    end

    test "ignores changes if the player id is invalid" do
      state = build_pong_state(player_right: true, player_left: true)

      assert {:reply, :ok, new_state} =
               Engine.handle_call({:leave, :fake_id}, self(), state)

      assert new_state.player_left
      assert new_state.player_right
    end

    test "adds an event if a player leaves" do
      state = build_pong_state(player_right: true, player_left: true)

      assert {:reply, :ok, new_state} =
               Engine.handle_call({:leave, :right}, self(), state)

      assert new_state.events == [{"player_left", %{player: :right}}]
    end

    test "waits for the pending cycle" do
      # This is a pretty complicated test to do. The way I achieved it was by
      # spawning a process that would block on the handle cast for a long time
      # and send a message before that. We can then assert that it blocked by
      # refuting having received before the period had passed and asserting to
      # have received after it did. We can take this test further by spawning
      # the same process again but sending the :work message immediately and
      # asserting that it replied back
      state = build_pong_state(player_right: true, period: 200)
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
            player_left: true,
            player_right: true
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
            player_left: true,
            player_right: true
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
        state = build_pong_state(player_left: true, player_right: true)

        {:noreply, _} = Engine.handle_info(:work, state)

        assert called(Movement.apply_to(state.game, state.movements))
      end
    end

    test "resets the movement buffer" do
      with_mock Movement, apply_to: fn _, _ -> {[], :ok} end do
        state = build_pong_state(player_left: true, player_right: true)

        {:noreply, new_state} = Engine.handle_info(:work, state)

        assert new_state.movements == Movement.Buffer.new()
      end
    end

    test "updates the game events" do
      mock_apply_to = fn game, _ -> {[{"a new", "event"}], game} end

      with_mock Movement, apply_to: mock_apply_to do
        state = build_pong_state(player_left: true, player_right: true)

        {:noreply, new_state} = Engine.handle_info(:work, state)

        assert new_state.events == [{"a new", "event"}]
      end
    end

    test "uses the start delay if there was a point scored" do
      mock_apply_to = fn game, _ -> {[{"player_scored", %{}}], game} end

      with_mock Movement, apply_to: mock_apply_to do
        state =
          build_pong_state(
            player_left: true,
            player_right: true,
            start_delay: 1,
            period: 1_000
          )

        {:noreply, _} = Engine.handle_info(:work, state)

        assert_receive :work
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
      events: []
    ]
    |> Keyword.merge(overrides)
    |> Enum.into(%{})
  end
end
