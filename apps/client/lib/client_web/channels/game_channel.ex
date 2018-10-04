defmodule ClientWeb.Channels.GameChannel do
  use Phoenix.Channel

  def join("game:lobby", _params, socket) do
    {:ok, socket}
  end

  def join("game:board", _params, socket) do
    {:ok, socket}
  end

  def join("game:play", _params, socket) do
    case Pong.join() do
      {:ok, %{player_id: player_id} = player_data} ->
        {:ok, player_data, assign(socket, :player_id, player_id)}

      {:error, :game_full} ->
        {:error, %{reason: "game full"}}
    end
  end

  def terminate(_msg, %{assigns: %{player_id: player_id}}) do
    Pong.leave(player_id)
  end

  def terminate(_, _), do: :ok

  def handle_in(
        "player:move",
        %{"direction" => direction},
        %{assigns: %{player_id: _}} = socket
      )
      when direction in ["up", "down"] do
    Pong.move(socket.assigns.player_id, String.to_atom(direction))

    {:noreply, socket}
  end

  def handle_in("player:move", _, socket), do: {:noreply, socket}
end
