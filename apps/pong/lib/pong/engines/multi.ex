defmodule Pong.Engines.Multi do
  use Pong.Engine

  def add_player(nil, _), do: {:ok, :left, 1}
  def add_player(_, nil), do: {:ok, :right, 1}

  def add_player(left, right)
      when left > 200 or right > 200,
      do: {:error, :game_full}

  def add_player(left, right)
      when left <= right,
      do: {:ok, :left, left + 1}

  def add_player(left, right)
      when right < left,
      do: {:ok, :right, right + 1}

  def remove_player(_, nil),
    do: {:error, :invalid_player}

  def remove_player(_, value)
      when value > 0,
      do: {:ok, value - 1}

  def remove_player(:right, right)
      when right > 0,
      do: {:ok, right - 1}

  def remove_player(_, _),
    do: {:error, :invalid_player}

  def players_ready?(left, right),
    do: left && left > 0 && right && right > 0
end
