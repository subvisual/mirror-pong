defmodule Pong.RendererTest do
  use ExUnit.Case
  doctest Pong.Renderer

  alias Pong.Renderer

  import Pong.Factory
  import Mock

  describe "init/1" do
    test "creates the correct state" do
      {:ok, state} = Renderer.init(:ok)

      assert %{
               fps: _,
               period: _,
               subscriptions: [],
               game: nil
             } = state
    end
  end

  describe "handle_cast/2 for :start messages" do
    test "schedules work according to the delay argument" do
      state = build_state()
      game = build(:game)

      {:noreply, _} = Renderer.handle_cast({:start, game, 50}, state)

      refute_receive :work, 10
      assert_receive :work, 100
    end

    test "broadcasts the game and the delay" do
      subscriptions = [fn data -> send self(), data end]
      state = build_state(subscriptions: subscriptions)
      game = build(:game)

      {:noreply, _} = Renderer.handle_cast({:start, game, 10}, state)

      assert_receive {"game_starting", %{"delay" => _, "game" => _}}
    end
  end

  describe "handle_cast/2 for :stop messages" do
    # This is a pretty complicated test to do. The way I achieved it was by
    # spawning a process that would block on the handle cast for a long time
    # and send a message before that. We can then assert that it blocked by
    # refuting having received before the period had passed and asserting to
    # have received after it did. We can take this test further by spawning
    # the same process again but sending the :work message immediately and
    # asserting that it replied back
    test "waits for the pending work message" do
      state = build_state(period: 200)
      pid = self()

      spawn fn ->
        Renderer.handle_cast(:stop, state)

        send pid, :checkpoint_1
      end

      refute_receive :checkpoint_1, 100
      assert_receive :checkpoint_1, 500

      child_pid =
        spawn fn ->
          Renderer.handle_cast(:stop, state)

          send pid, :checkpoint_2
        end

      send child_pid, :work

      assert_receive :checkpoint_2, 100
    end

    test "resets the game state cache" do
      state = build_state()

      {:noreply, new_state} = Renderer.handle_cast(:stop, state)

      refute new_state.game
    end
  end

  describe "handle_cast/2 for :subscribe messages" do
    test "updates the subscription list" do
      fun = fn data -> send self(), data end
      state = build_state()

      {:noreply, new_state} = Renderer.handle_cast({:subscribe, fun}, state)

      assert [fun] == new_state.subscriptions
    end
  end

  describe "handle_info/2 for :work messages" do
    test "broadcasts the game state to all subscriptions" do
      with_mock Pong.Engine, state: fn -> :ok end do
        subscriptions = [fn data -> send self(), data end]
        state = build_state(subscriptions: subscriptions)

        {:noreply, _} = Renderer.handle_info(:work, state)

        assert_receive {"data", :ok}
      end
    end
  end

  describe "handle_call/3 for :current_state messages" do
    test "errors if the game hasn't started" do
      state = build_state(game: nil)

      {:reply, reply, _} = Renderer.handle_call(:current_state, self(), state)

      assert {:error, :not_started} = reply
    end

    test "returns the game if it has started" do
      game = build(:game)
      state = build_state(game: game)

      {:reply, reply, _} = Renderer.handle_call(:current_state, self(), state)

      assert {:ok, ^game} = reply
    end
  end

  defp build_state(overrides \\ []) do
    [
      fps: 60,
      period: Kernel.trunc(1 / 60 * 1_000),
      subscriptions: [],
      game: nil
    ]
    |> Keyword.merge(overrides)
    |> Enum.into(%{})
  end
end
