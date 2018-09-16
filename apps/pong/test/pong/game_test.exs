defmodule Pong.GameTest do
  use ExUnit.Case
  doctest Pong.Game

  alias Pong.Game

  import Pong.Factory

  describe "move/3" do
    test "updates the correct paddle" do
      game = build(:game)

      updated_game = Game.move(game, :left, :up)

      assert updated_game.paddle_right == game.paddle_right
      refute updated_game.paddle_left.y == game.paddle_left.y
    end
  end
end
