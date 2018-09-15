defmodule Client.PongSubscription do
  def create do
    Pong.subscribe(&broadcast_data/1)
  end

  defp broadcast_data(data) do
    ClientWeb.Endpoint.broadcast("game:board", "data", data)
  end
end
