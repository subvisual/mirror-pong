defmodule ClientWeb.UserSocket do
  use Phoenix.Socket

  channel("game:*", ClientWeb.Channels.GameChannel)

  transport(:websocket, Phoenix.Transports.WebSocket, timeout: 45_000)

  def connect(_params, socket), do: {:ok, socket}

  def id(_socket), do: nil
end
