defmodule Client.GameTest do
  use ClientWeb.ChannelCase

  alias ClientWeb.Channels.GameChannel

  setup do
    case Pong.start_link([]) do
      {:ok, _} ->
        ClientWeb.PongSubscription.create()
        :ok

      _ ->
        :ok
    end
  end

  describe "gameplay" do
    test "updates watchers on every move" do
      {:ok, _, controller_socket} =
        socket()
        |> subscribe_and_join(GameChannel, "game:play")

      {:ok, initial_state, _game_socket} =
        socket()
        |> subscribe_and_join(GameChannel, "game:board")

      push(controller_socket, "player:move", %{"direction" => "up"})

      assert_broadcast("data", data)

      assert data.game.paddle_left.y > initial_state.game.paddle_left.y
    end
  end
end
