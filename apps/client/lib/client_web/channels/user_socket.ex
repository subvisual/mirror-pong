defmodule ClientWeb.UserSocket do
  use Phoenix.Socket

  channel("game:*", ClientWeb.Channels.GameChannel)

  transport(:websocket, Phoenix.Transports.WebSocket)

  def connect(_params, socket), do: {:ok, socket}

  def id(socket), do: nil
end
