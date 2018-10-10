defmodule Pong do
  defdelegate subscribe(fun), to: Pong.Renderer
  defdelegate current_state, to: Pong.Renderer
  defdelegate join, to: Pong.Engine
  defdelegate leave(player_id), to: Pong.Engine
  defdelegate stop, to: Pong.Engine
  defdelegate move(player, direction), to: Pong.Engine
end
