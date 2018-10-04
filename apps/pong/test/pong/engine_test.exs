defmodule Pong.EngineTest do
  use ExUnit.Case
  doctest Pong.Engine

  alias Pong.Engine

  import Pong.Factory
  import Mock

  describe "init/1" do
    test "creates the correct state" do
      {:ok, state} = Engine.init(:ok)

      assert %{
               game: _,
               fps: _,
               period: _,
               player_left: nil,
               player_right: nil
             } = state
    end
  end

  describe "handle_cast/2 for :move messages" do
    test "moves the player in the game" do
      with_mock Pong.Game, move: fn game, _, _ -> game end do
        game = build(:game)
        state = build_pong_state(game: game)

        Engine.handle_cast({:move, :left, :up}, state)

        assert called(Pong.Game.move(game, :left, :up))
      end
    end

    test "returns the state with an updated game" do
      game = build(:game)
      state = build_pong_state(game: game)

      {:noreply, %{game: new_game}} =
        Engine.handle_cast({:move, :left, :up}, state)

      assert new_game.paddle_left.y > game.paddle_left.y
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
      with_mock Pong.Renderer, start: fn -> :ok end do
        state = build_pong_state(player_left: true)
        {:reply, _, new_state} = Engine.handle_call(:join, self(), state)

        assert new_state[:player_right]
      end
    end

    test "starts the renderer" do
      with_mock Pong.Renderer, start: fn -> :ok end do
        state = build_pong_state(player_left: true)
        {:reply, _, _} = Engine.handle_call(:join, self(), state)

        assert called(Pong.Renderer.start())
      end
    end

    test "schedules work if all players are ready" do
      with_mock Pong.Renderer, start: fn -> :ok end do
        state = build_pong_state(player_left: true, period: 1)
        {:reply, _, _} = Engine.handle_call(:join, self(), state)

        assert_receive :work, 100
      end
    end

    test "doesn't schedule work when a player is missing" do
      state = build_pong_state(period: 1)

      {:reply, _, _} = Engine.handle_call(:join, self(), state)

      refute_receive :work, 100
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
      state = build_pong_state(player_right: true)

      assert {:reply, :ok, ^state} =
               Engine.handle_call({:leave, :fake_id}, self(), state)
    end
  end

  describe "handle_call/3 for :state messages" do
    test "returns the game state" do
      state = build_pong_state()
      game_state = %{game: state.game, players: %{left: nil, right: nil}}

      assert {:reply, ^game_state, ^state} =
               Engine.handle_call(:state, self(), state)
    end
  end

  describe "handle_call/3 for :stop messages" do
    test "resets the state" do
      with_mock Pong.Renderer, stop: fn -> :ok end do
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
      with_mock Pong.Renderer, stop: fn -> :ok end do
        state =
          build_pong_state(
            player_left: true,
            player_right: true
          )

        {:reply, _, _} = Engine.handle_call(:stop, self(), state)

        assert called(Pong.Renderer.stop())
      end
    end
  end

  defp build_pong_state(overrides \\ []) do
    [
      game: build(:game),
      fps: 60,
      period: Kernel.trunc(1 / 60 * 1_000),
      player_left: nil,
      player_right: nil
    ]
    |> Keyword.merge(overrides)
    |> Enum.into(%{})
  end
end
