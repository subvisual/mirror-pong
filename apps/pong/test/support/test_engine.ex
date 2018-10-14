defmodule Pong.TestEngine do
  use Pong.Engine

  defdelegate add_player(left, right), to: Pong.Engines.Singles
  defdelegate remove_player(player_ref, player), to: Pong.Engines.Singles
  defdelegate players_ready?(left, right), to: Pong.Engines.Singles
end
