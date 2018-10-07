defmodule ClientWeb.PongSubscription do
  def create do
    Pong.subscribe(&broadcast/1)
  end

  defp broadcast({"data", data}) do
    ClientWeb.Endpoint.broadcast("game:board", "data", data)
  end

  defp broadcast({event, data}) do
    ClientWeb.Endpoint.broadcast("game:board", event, data)
  end
end
