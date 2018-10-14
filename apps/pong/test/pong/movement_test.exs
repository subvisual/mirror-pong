defmodule Pong.MovementTest do
  use ExUnit.Case
  doctest Pong.Movement

  alias Pong.{
    Game,
    Game.Ball,
    Movement
  }

  import Pong.Factory

  describe "apply_to/2" do
    test "increments the paddle's y coordinate if moving up" do
      %Game{paddle_left: paddle} = game = build(:game)
      buffer = build(:movement_buffer, left: %{up: 1, down: 0})

      {_, %Game{paddle_left: updated_paddle}} = Movement.apply_to(game, buffer)

      assert updated_paddle.y > paddle.y
    end

    test "decrements the paddle's y coordinate if moving down" do
      %Game{paddle_left: paddle} = game = build(:game)
      buffer = build(:movement_buffer, left: %{up: 0, down: 1})

      {_, %Game{paddle_left: updated_paddle}} = Movement.apply_to(game, buffer)

      assert updated_paddle.y < paddle.y
    end

    test "prevents the paddle from overflowing off the top of the game board" do
      board = build(:board)
      # position the paddle center 1 unit above the board edge
      paddle = build(:paddle, height: 100, y: board.height - 51)
      game = build(:game, paddle_left: paddle, board: board)
      buffer = build(:movement_buffer, left: %{up: 1, down: 0})

      {_, %Game{paddle_left: updated_paddle}} = Movement.apply_to(game, buffer)

      assert updated_paddle.y == board.height - 50
    end

    test "prevents the paddle from overflowing off the bottom of the game board" do
      board = build(:board)
      # position the paddle center 1 unit above the board edge
      paddle = build(:paddle, height: 100, y: 51)
      game = build(:game, paddle_left: paddle, board: board)
      buffer = build(:movement_buffer, left: %{up: 0, down: 1})

      {_, %Game{paddle_left: updated_paddle}} = Movement.apply_to(game, buffer)

      assert updated_paddle.y == 50
    end

    test "updates the ball coordinates using the vector and the speed" do
      buffer = build(:movement_buffer)
      ball = build(:ball, vector_x: 1, vector_y: -1, speed: 2)
      game = build(:game, ball: ball)

      {_, %Game{ball: %Ball{x: x, y: y}}} = Movement.apply_to(game, buffer)

      assert x == ball.x + 2
      assert y == ball.y - 2
    end

    test "prevents the ball from overflowing off the game board" do
      board = build(:board)
      buffer = build(:movement_buffer)

      # all balls are 1 unit away from their respective wall
      top_wall_ball =
        build(:ball, radius: 5, y: board.height - 6, vector_y: 1, speed: 1)

      bottom_wall_ball = build(:ball, radius: 5, y: 6, vector_y: -1, speed: 1)

      game = build(:game, board: board)

      {_, %Game{ball: %Ball{y: top_wall_ball_y}}} =
        Movement.apply_to(%{game | ball: top_wall_ball}, buffer)

      {_, %Game{ball: %Ball{y: bottom_wall_ball_y}}} =
        Movement.apply_to(%{game | ball: bottom_wall_ball}, buffer)

      assert top_wall_ball_y == board.height - top_wall_ball.radius
      assert bottom_wall_ball_y == bottom_wall_ball.radius
    end

    test "updates the ball vector when colliding with the wall" do
      buffer = build(:movement_buffer)
      board = build(:board)

      # all balls are 1 unit away from their respective wall
      top_wall_ball =
        build(:ball,
          radius: 5,
          x: board.width / 2,
          y: board.height - 6,
          vector_y: 1,
          speed: 1
        )

      bottom_wall_ball =
        build(:ball, radius: 5, x: board.width / 2, y: 6, vector_y: -1, speed: 1)

      game = build(:game, board: board)

      {_, %Game{ball: %Ball{vector_y: top_wall_vector_y}}} =
        Movement.apply_to(%{game | ball: top_wall_ball}, buffer)

      {_, %Game{ball: %Ball{vector_y: bottom_wall_vector_y}}} =
        Movement.apply_to(%{game | ball: bottom_wall_ball}, buffer)

      assert top_wall_vector_y == -top_wall_ball.vector_y
      assert bottom_wall_vector_y == -bottom_wall_ball.vector_y
    end

    test "updates the ball vector when colliding with the paddles" do
      buffer = build(:movement_buffer)
      board = build(:board)
      left_paddle = build(:paddle, x: 30, y: board.height / 2)
      right_paddle = build(:paddle, x: board.width - 30, y: board.height / 2)

      # both balls are 1 unit away from their respective paddle
      leftside_ball =
        build(:ball,
          radius: 5,
          y: board.height / 2,
          x: 36,
          vector_x: -1,
          vector_y: 0,
          speed: 10
        )

      rightside_ball =
        build(:ball,
          radius: 5,
          y: board.height / 2,
          x: board.width - 36,
          vector_x: 1,
          vector_y: 0,
          speed: 10
        )

      game =
        build(:game,
          board: board,
          paddle_left: left_paddle,
          paddle_right: right_paddle
        )

      {_, %Game{ball: updated_leftside_ball}} =
        Movement.apply_to(%{game | ball: leftside_ball}, buffer)

      {_, %Game{ball: updated_rightside_ball}} =
        Movement.apply_to(%{game | ball: rightside_ball}, buffer)

      assert updated_leftside_ball.vector_x == -leftside_ball.vector_x
      assert updated_rightside_ball.vector_x == -rightside_ball.vector_x
    end

    test "updates the left player score when the ball is past the left paddle" do
      # move the paddle out of the way
      paddle = build(:left_paddle, y: 50, height: 100)
      # ball is one unit away from being past the left paddle
      ball_x = paddle.x - paddle.width / 2 + 1
      ball = build(:ball, x: ball_x, speed: 10, vector_x: -1, vector_y: 0)
      game = build(:game, paddle_left: paddle, ball: ball)
      buffer = build(:movement_buffer)

      {_, updated_game} = Movement.apply_to(game, buffer)

      assert updated_game.score_left > game.score_left
    end

    test "updates the right player score when the ball is past the right paddle" do
      # move the paddle out of the way
      paddle = build(:right_paddle, y: 50, height: 100)
      # ball is one unit away from being past the right paddle
      ball_x = paddle.x + paddle.width / 2 - 1
      ball = build(:ball, x: ball_x, speed: 10, vector_x: 1, vector_y: 0)
      game = build(:game, paddle_right: paddle, ball: ball)
      buffer = build(:movement_buffer)

      {_, updated_game} = Movement.apply_to(game, buffer)

      assert updated_game.score_right > game.score_right
    end

    test "returns an event if a player scored" do
      # move the paddle out of the way
      paddle = build(:right_paddle, y: 50, height: 100)
      # ball is one unit away from being past the right paddle
      ball_x = paddle.x + paddle.width / 2 - 1
      ball = build(:ball, x: ball_x, speed: 10, vector_x: 1, vector_y: 0)
      game = build(:game, paddle_right: paddle, ball: ball)
      buffer = build(:movement_buffer)

      assert {[{"player_scored", _} | _], _} = Movement.apply_to(game, buffer)
    end

    test "includes a game_over event if the game is over" do
      # move the paddle out of the way
      paddle = build(:right_paddle, y: 50, height: 100)
      # ball is one unit away from being past the right paddle
      ball_x = paddle.x + paddle.width / 2 - 1
      ball = build(:ball, x: ball_x, speed: 10, vector_x: 1, vector_y: 0)

      game =
        build(:game,
          paddle_right: paddle,
          ball: ball,
          score_right: 2,
          score_limit: 3
        )

      buffer = build(:movement_buffer)

      {events, _} = Movement.apply_to(game, buffer)

      assert Enum.find(events, false, fn {e, _} -> e == "game_over" end)
    end
  end
end
