defmodule Pong do
  defdelegate subscribe(fun), to: Pong.Renderer
  defdelegate current_state, to: Pong.Renderer
  defdelegate join, to: Pong.Engines.Multi
  defdelegate leave(player_id), to: Pong.Engines.Multi
  defdelegate stop, to: Pong.Engines.Multi
  defdelegate move(player, direction), to: Pong.Engines.Multi
end
