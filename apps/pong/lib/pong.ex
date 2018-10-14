defmodule Pong do
  defdelegate subscribe(fun), to: Pong.Renderer
  defdelegate current_state, to: Pong.Renderer
  defdelegate join, to: Pong.Engines.Singles
  defdelegate leave(player_id), to: Pong.Engines.Singles
  defdelegate stop, to: Pong.Engines.Singles
  defdelegate move(player, direction), to: Pong.Engines.Singles
end
