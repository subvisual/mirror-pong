defmodule Pong.GameTest do
  use ExUnit.Case
  doctest Pong.Game

  alias Pong.Game

  import Pong.Factory

  describe "score/2" do
    test "updates the correct score" do
      game = build(:game)

      {:player_scored, game_with_score_left} = Game.score(game, :left)
      {:player_scored, game_with_score_right} = Game.score(game, :right)

      assert game_with_score_left.score_left == 1
      assert game_with_score_left.score_right == 0
      assert game_with_score_right.score_right == 1
      assert game_with_score_right.score_left == 0
    end

    test "resets the game positions" do
      paddle = build(:paddle, y: 200)
      game = build(:game, paddle_left: paddle)

      {_, updated_game} = Game.score(game, :left)

      refute updated_game.paddle_left == paddle
    end

    test "returns the correct indicator if the game is over" do
      game = build(:game, score_limit: 3, score_left: 2)

      {:game_over, updated_game} = Game.score(game, :left)

      assert updated_game.paddle_left == game.paddle_left
      assert updated_game.paddle_right == game.paddle_right
      assert updated_game.ball == game.ball
    end
  end
end
