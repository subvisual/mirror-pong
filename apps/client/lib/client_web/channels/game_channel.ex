defmodule ClientWeb.Channels.GameChannel do
  use Phoenix.Channel

  def join("game:lobby", _params, socket) do
    {:ok, socket}
  end

  def join("game:play", _params, socket) do
    case Pong.join() do
      {:ok, player_id} ->
        {:ok, %{player_id: player_id}, assign(socket, :player_id, player_id)}

      {:error, :game_full} ->
        {:error, %{reason: "game full"}}
    end
  end

  def terminate(msg, socket) do
    Pong.leave(socket.assigns.player_id)
  end

  def handle_in("player:move", %{"direction" => direction}, socket)
      when direction in ["up", "down"] do
    Pong.move(socket.assigns.player_id, String.to_atom(direction))

    {:noreply, socket}
  end

  def handle_in("player:move", _, socket), do: {:noreply, socket}
end
