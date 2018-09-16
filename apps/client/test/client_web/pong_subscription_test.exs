defmodule ClientWeb.PongSubscriptionTest do
  use ClientWeb.ChannelCase

  import Mock

  alias ClientWeb.Channels.GameChannel
  alias ClientWeb.PongSubscription

  describe "create/1" do
    test "adds a subscription to the pong process" do
      test_pid = self()

      with_mock Pong, subscribe: fn _ -> send test_pid, :called end do
        PongSubscription.create()

        # We can't use assert called since we don't have access to the
        # anonymous function
        assert_received :called
      end
    end

    test "broadcasts data when the subscription is invoked" do
      test_pid = self()

      with_mock Pong,
        game_state: fn -> :ok end,
        subscribe: fn fun -> send test_pid, fun end do
        socket()
        |> subscribe_and_join(GameChannel, "game:board")

        PongSubscription.create()

        assert_received fun
        fun.(%{"game" => :ok})

        assert_broadcast("data", %{"game" => :ok})
      end
    end
  end
end
