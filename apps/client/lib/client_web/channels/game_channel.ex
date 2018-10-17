defmodule ClientWeb.Channels.GameChannel do
  use Phoenix.Channel

  def join("game:lobby", _params, socket) do
    {:ok, socket}
  end

  def join("game:board", _params, socket) do
    {:ok, socket}
  end

  def join("game:metadata", _params, socket) do
    case Pong.current_state() do
      {:ok, game} ->
        {:ok, %{game: game}, socket}

      {:error, :not_started} ->
        {:ok, socket}
    end
  end

  def join("game:play", _params, socket) do
    case Pong.join() do
      {:ok, %{player_id: id, player_side: side} = player_data} ->
        socket_with_assigns =
          socket
          |> assign(:player_id, id)
          |> assign(:player_side, side)

        {:ok, player_data, socket_with_assigns}

      {:error, :game_full} ->
        {:error, %{reason: "game full"}}
    end
  end

  def terminate(_msg, %{assigns: %{player_id: _}} = socket) do
    %{player_id: id, player_side: side} = socket.assigns

    Pong.leave({id, side})
  end

  def terminate(_, _), do: :ok

  def handle_in(
        "player:move",
        %{"direction" => direction},
        %{assigns: %{player_id: _, player_side: side}} = socket
      )
      when direction in ["up", "down"] do
    Pong.move(side, String.to_atom(direction))

    {:noreply, socket}
  end

  def handle_in("player:move", _, socket), do: {:noreply, socket}
end
