defmodule ClientWeb.Channels.GameChannelTest do
  use ClientWeb.ChannelCase

  alias ClientWeb.Channels.GameChannel

  import Mock

  @default_player_data %{player_id: :left, paddle_color: "black"}

  describe "join game:board" do
    test "returns the current game state" do
      Pong.start_link([])

      assert {:ok, %Pong.Game{}, _} =
               socket()
               |> subscribe_and_join(GameChannel, "game:board")
    end
  end

  describe "join game:play" do
    test "returns and assigns a player id and paddle color if there are spots available" do
      with_mock Pong, join: fn -> {:ok, @default_player_data} end do
        assert {:ok, %{player_id: :left, paddle_color: _}, socket} =
                 socket()
                 |> subscribe_and_join(GameChannel, "game:play")

        assert %{assigns: %{player_id: :left}} = socket
      end
    end

    test "errors if the game is full" do
      with_mock Pong, join: fn -> {:error, :game_full} end do
        assert {:error, %{reason: "game full"}} =
                 socket() |> subscribe_and_join(GameChannel, "game:play")
      end
    end
  end

  describe "terminate" do
    test "leaves the game if there is a player assigned" do
      with_mock Pong,
        join: fn -> {:ok, @default_player_data} end,
        leave: fn _ -> :ok end do
        {:ok, _, socket} =
          socket()
          |> subscribe_and_join(GameChannel, "game:play")

        socket
        |> close()

        assert called(Pong.leave(:left))
      end
    end
  end

  describe "handling of player:move" do
    test "ignores if the direction is invalid" do
      with_mock Pong,
        join: fn -> {:ok, @default_player_data} end,
        move: fn _, _ -> :ok end do
        {:ok, _, socket} =
          socket()
          |> subscribe_and_join(GameChannel, "game:play")

        push(socket, "player:move", %{"direction" => "left"})

        refute called(Pong.move(:left, :left))
      end
    end

    test "ignores if the socket has no player assigned" do
      test_pid = self()

      with_mock Pong,
        move: fn _, _ -> send test_pid, :called end do
        {:ok, _, socket} =
          socket()
          |> subscribe_and_join(GameChannel, "game:lobby")

        push(socket, "player:move", %{"direction" => "up"})

        refute_received :called
      end
    end

    test "calls the pong game to move the player" do
      test_pid = self()

      with_mock Pong,
        join: fn -> {:ok, @default_player_data} end,
        move: fn player, direction -> send test_pid, {player, direction} end do
        {:ok, _, socket} =
          socket()
          |> subscribe_and_join(GameChannel, "game:play")

        push(socket, "player:move", %{"direction" => "up"})

        # Note: ideally we would use assert called here
        # However the socket is running asynchronously, so sometimes we would
        # be asserting even though the socket had no time to run
        assert_receive {:left, :up}
      end
    end
  end
end
