defmodule Pong.GameTest do
  use ExUnit.Case
  doctest Pong.Game

  alias Pong.Game

  import Pong.Factory

  describe "score/2" do
    test "updates the correct score" do
      game = build(:game)

      game_with_score_left = Game.score(game, :left)
      game_with_score_right = Game.score(game, :right)

      assert game_with_score_left.score_left == 1
      assert game_with_score_left.score_right == 0
      assert game_with_score_right.score_right == 1
      assert game_with_score_right.score_left == 0
    end

    test "resets the game positions" do
      paddle = build(:paddle, y: 200)
      game = build(:game, paddle_left: paddle)

      updated_game = Game.score(game, :left)

      refute updated_game.paddle_left == paddle
    end
  end
end
