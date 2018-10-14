defmodule Client.GameTest do
  use ClientWeb.ChannelCase

  alias ClientWeb.Channels.GameChannel

  setup do
    with {:ok, _} <- Pong.Engines.Singles.start_link([]),
         {:ok, _} <- Pong.Renderer.start_link([]) do
      ClientWeb.PongSubscription.create()

      :ok
    else
      _error -> :ok
    end
  end

  describe "gameplay" do
    test "updates watchers on every move" do
      {initial_state, []} = Pong.Engines.Singles.consume()

      {:ok, _, _game_socket} =
        socket()
        |> subscribe_and_join(GameChannel, "game:board")

      {:ok, _, _metadata_socket} =
        socket()
        |> subscribe_and_join(GameChannel, "game:metadata")

      {:ok, _, controller_socket} =
        socket()
        |> subscribe_and_join(GameChannel, "game:play")

      {:ok, _, _} =
        socket()
        |> subscribe_and_join(GameChannel, "game:play")

      assert_broadcast("game_starting", %{"delay" => _, "game" => _}, 150)

      push(controller_socket, "player:move", %{"direction" => "up"})

      assert_broadcast("data", game, 200)

      assert game.paddle_left.y > initial_state.paddle_left.y
    end
  end
end
