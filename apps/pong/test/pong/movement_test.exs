defmodule Pong.MovementTest do
  use ExUnit.Case
  doctest Pong.Movement

  alias Pong.{Game, Movement}

  alias Pong.Game.{
    Ball,
    Paddle
  }

  import Pong.Factory

  describe "apply_to/3" do
    test "increments the y coordinate if moving up" do
      paddle = build(:paddle)
      board = build(:board)

      %Paddle{y: y} = Movement.apply_to(paddle, :up, board)

      assert y > paddle.y
    end

    test "decrements the y coordinate if moving down" do
      paddle = build(:paddle)
      board = build(:board)

      %Paddle{y: y} = Movement.apply_to(paddle, :down, board)

      assert y < paddle.y
    end

    test "prevents the paddle from overflowing off the top of the game board" do
      board = build(:board)
      # position the paddle center 1 unit below the board edge
      paddle = build(:paddle, height: 100, y: board.height - 51)

      %Paddle{y: y} = Movement.apply_to(paddle, :up, board)

      assert y == board.height - 50
    end

    test "prevents the paddle from overflowing off the bottom of the game board" do
      board = build(:board)
      # position the paddle center 1 unit above the board edge
      paddle = build(:paddle, height: 100, y: 51)

      %Paddle{y: y} = Movement.apply_to(paddle, :down, board)

      assert y == 50
    end
  end

  describe "apply_to/1" do
    test "updates the ball coordinates using the vector and the speed" do
      ball = build(:ball, vector_x: 1, vector_y: -1, speed: 2)
      game = build(:game, ball: ball)

      %Game{ball: %Ball{x: x, y: y}} = Movement.apply_to(game)

      assert x == ball.x + 2
      assert y == ball.y - 2
    end

    test "prevents the ball from overflowing off the game board" do
      board = build(:board)

      # all balls are 1 unit away from their respective wall
      top_wall_ball =
        build(:ball, radius: 5, y: board.height - 6, vector_y: 1, speed: 10)

      right_wall_ball =
        build(:ball, radius: 5, x: board.width - 6, vector_x: 1, speed: 10)

      bottom_wall_ball = build(:ball, radius: 5, y: 6, vector_y: -1, speed: 10)
      left_wall_ball = build(:ball, radius: 5, x: 6, vector_x: -1, speed: 10)

      game = build(:game, board: board)

      %Game{ball: %Ball{y: top_wall_ball_y}} =
        Movement.apply_to(%{game | ball: top_wall_ball})

      %Game{ball: %Ball{x: right_wall_ball_x}} =
        Movement.apply_to(%{game | ball: right_wall_ball})

      %Game{ball: %Ball{y: bottom_wall_ball_y}} =
        Movement.apply_to(%{game | ball: bottom_wall_ball})

      %Game{ball: %Ball{x: left_wall_ball_x}} =
        Movement.apply_to(%{game | ball: left_wall_ball})

      assert top_wall_ball_y == board.height - top_wall_ball.radius
      assert right_wall_ball_x == board.height - right_wall_ball.radius
      assert bottom_wall_ball_y == bottom_wall_ball.radius
      assert left_wall_ball_x == left_wall_ball.radius
    end

    test "updates the ball vector when colliding with the wall" do
      board = build(:board)
      # move the paddles out of the way
      paddle = build(:paddle, x: -100, y: -100)

      # all balls are 1 unit away from their respective wall
      top_wall_ball =
        build(:ball, radius: 5, y: board.height - 6, vector_y: 1, speed: 10)

      right_wall_ball =
        build(:ball, radius: 5, x: board.width - 6, vector_x: 1, speed: 10)

      bottom_wall_ball = build(:ball, radius: 5, y: 6, vector_y: -1, speed: 10)
      left_wall_ball = build(:ball, radius: 5, x: 6, vector_x: -1, speed: 10)

      game =
        build(:game, board: board, paddle_left: paddle, paddle_right: paddle)

      %Game{ball: %Ball{vector_y: top_wall_vector_y}} =
        Movement.apply_to(%{game | ball: top_wall_ball})

      %Game{ball: %Ball{vector_x: right_wall_vector_x}} =
        Movement.apply_to(%{game | ball: right_wall_ball})

      %Game{ball: %Ball{vector_y: bottom_wall_vector_y}} =
        Movement.apply_to(%{game | ball: bottom_wall_ball})

      %Game{ball: %Ball{vector_x: left_wall_vector_x}} =
        Movement.apply_to(%{game | ball: left_wall_ball})

      assert top_wall_vector_y == -top_wall_ball.vector_y
      assert right_wall_vector_x == -right_wall_ball.vector_x
      assert bottom_wall_vector_y == -bottom_wall_ball.vector_y
      assert left_wall_vector_x == -left_wall_ball.vector_x
    end

    test "updates the vector when colliding with the paddles" do
      board = build(:board)
      left_paddle = build(:paddle, x: 30, y: board.height / 2)
      right_paddle = build(:paddle, x: board.width - 30, y: board.height / 2)

      # bothh balls are 1 unit away from their respective paddle
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

      %Game{ball: updated_leftside_ball} =
        Movement.apply_to(%{game | ball: leftside_ball})

      %Game{ball: updated_rightside_ball} =
        Movement.apply_to(%{game | ball: rightside_ball})

      assert updated_leftside_ball.vector_x == -leftside_ball.vector_x
      assert updated_rightside_ball.vector_x == -rightside_ball.vector_x
    end
  end
end
