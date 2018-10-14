defmodule Pong.Engines.Singles do
  use Pong.Engine

  def add_player(nil, _), do: {:ok, :left, true}
  def add_player(_, nil), do: {:ok, :right, true}
  def add_player(_, _), do: {:error, :game_full}

  def remove_player(:left, true), do: {:ok, nil}
  def remove_player(:right, true), do: {:ok, nil}
  def remove_player(_, _), do: {:error, :invalid_player}

  def players_ready?(left, right), do: left && right
end
