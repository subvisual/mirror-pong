defmodule PongTest do
  use ExUnit.Case
  doctest Pong

  import Pong.Factory
  import Mock

  describe "init/1" do
    test "creates the correct state" do
      {:ok, state} = Pong.init(:ok)

      assert %{
               game: _,
               fps: _,
               period: _,
               player_left: nil,
               player_right: nil,
               subscriptions: []
             } = state
    end
  end

  describe "handle_cast/2 for :move messages" do
    test "moves the player in the game" do
      with_mock Pong.Game, move: fn game, _, _ -> game end do
        game = build(:game)
        state = build_pong_state(game: game)

        Pong.handle_cast({:move, :left, :up}, state)

        assert called(Pong.Game.move(game, :left, :up))
      end
    end

    test "broadcasts the state to the subscribers" do
      subscriptions = [fn data -> send self(), data end]
      state = build_pong_state(subscriptions: subscriptions)

      Pong.handle_cast({:move, :left, :up}, state)

      assert_received %{game: %Pong.Game{}}
    end

    test "returns the state with an updated game" do
      game = build(:game)
      state = build_pong_state(game: game)

      {:noreply, %{game: new_game}} =
        Pong.handle_cast({:move, :left, :up}, state)

      assert new_game.paddle_left.y > game.paddle_left.y
    end
  end

  describe "handle_cast/2 for :subscribe messages" do
    test "updates the subscriptions" do
      fun = fn data -> send self(), data end
      state = build_pong_state()

      {:noreply, new_state} = Pong.handle_cast({:subscribe, fun}, state)

      assert [fun] == new_state.subscriptions
    end
  end

  describe "handle_call/3 for :join messages" do
    test "errors if the game is full" do
      state = build_pong_state(player_left: true, player_right: true)

      {:reply, error, _} = Pong.handle_call(:join, self(), state)

      assert {:error, :game_full} == error
    end

    test "adds the left player if no players have joined" do
      state = build_pong_state()

      {:reply, _, new_state} = Pong.handle_call(:join, self(), state)

      assert new_state[:player_left]
    end

    test "adds the right player if there is a left player" do
      state = build_pong_state(player_left: true)

      {:reply, _, new_state} = Pong.handle_call(:join, self(), state)

      assert new_state[:player_right]
    end

    test "schedules work if all players are ready" do
      state = build_pong_state(player_left: true, period: 1)

      {:reply, _, _} = Pong.handle_call(:join, self(), state)

      assert_receive :work, 100
    end

    test "doesn't return schedule work when a player is missing" do
      state = build_pong_state(period: 1)

      {:reply, _, _} = Pong.handle_call(:join, self(), state)

      refute_receive :work, 100
    end

    test "returns the player data" do
      state = build_pong_state()

      {:reply, {:ok, player_data}, _} = Pong.handle_call(:join, self(), state)

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
        Pong.handle_call({:leave, :right}, self(), state)

      refute new_state[:player_right]
    end

    test "ignores changes if the player id is invalid" do
      state = build_pong_state(player_right: true)

      assert {:reply, :ok, ^state} =
               Pong.handle_call({:leave, :fake_id}, self(), state)
    end
  end

  describe "handle_call/3 for :game_state messages" do
    test "returns the game state" do
      state = build_pong_state()
      game = %{game: state.game, players: %{left: nil, right: nil}}

      assert {:reply, ^game, ^state} =
               Pong.handle_call(:game_state, self(), state)
    end
  end

  describe "handle_call/3 for :restart messages" do
    test "resets the state but keeps the subscriptions" do
      subscriptions = [fn data -> send self(), data end]

      state =
        build_pong_state(
          player_left: true,
          player_right: true,
          subscriptions: subscriptions
        )

      {:reply, _, new_state} = Pong.handle_call(:restart, self(), state)

      assert %{
               game: _,
               fps: _,
               player_left: nil,
               player_right: nil,
               subscriptions: ^subscriptions
             } = new_state
    end

    test "broadcasts the game restart to subscriptions" do
      subscriptions = [fn data -> send self(), data end]
      state = build_pong_state(subscriptions: subscriptions)

      Pong.handle_call(:restart, self(), state)

      assert_receive %{game: %Pong.Game{}}
    end
  end

  defp build_pong_state(overrides \\ []) do
    [
      game: build(:game),
      fps: 60,
      period: Kernel.trunc(1 / 60 * 1_000),
      player_left: nil,
      player_right: nil,
      subscriptions: []
    ]
    |> Keyword.merge(overrides)
    |> Enum.into(%{})
  end
end
