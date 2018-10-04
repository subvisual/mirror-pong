defmodule Client.GameTest do
  use ClientWeb.ChannelCase

  alias ClientWeb.Channels.GameChannel

  setup do
    with {:ok, _} <- Pong.Engine.start_link([]),
         {:ok, _} <- Pong.Renderer.start_link([]) do
      ClientWeb.PongSubscription.create()

      :ok
    else
      _error -> :ok
    end
  end

  describe "gameplay" do
    test "updates watchers on every move" do
      initial_state = Pong.Engine.state()

      {:ok, _, controller_socket} =
        socket()
        |> subscribe_and_join(GameChannel, "game:play")

      {:ok, _, _} =
        socket()
        |> subscribe_and_join(GameChannel, "game:play")

      {:ok, _, _game_socket} =
        socket()
        |> subscribe_and_join(GameChannel, "game:board")

      push(controller_socket, "player:move", %{"direction" => "up"})

      assert_broadcast("data", data)

      assert data.game.paddle_left.y > initial_state.game.paddle_left.y
    end
  end
end
