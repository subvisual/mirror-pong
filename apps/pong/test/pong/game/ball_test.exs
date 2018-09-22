defmodule Pong.Game.BallTest do
  use ExUnit.Case
  doctest Pong.Game.Ball

  alias Pong.Game.Ball

  import Pong.Factory

  # Randomness is always difficult to test. With these tests I want to ensure
  # that we are able to approximate randomness as much as possible to ensure
  # that the ball moves in directions that we consider "interesting" (not
  # straight in the horizontal or vertical or even close to that).
  #
  # The approach to test the randomness will be to generate a fair number of
  # values, collecting the uniqueness and ensuring that at over half are
  # different. If we generate more than one different outcome, we can consider
  # that to be "random enough"
  describe "new/0 vector generation" do
    test "generates a random vector" do
      vectors =
        1..100
        |> Stream.map(fn _ -> Ball.new() end)
        |> Stream.map(&{&1.vector_x, &1.vector_y})
        |> Enum.uniq()

      assert length(vectors) > 50
    end

    test "assigns a random sign to the vector" do
      {positive, negative} =
        1..100
        |> Stream.map(fn _ -> Ball.new() end)
        |> Stream.flat_map(&[&1.vector_x, &1.vector_y])
        |> Stream.uniq()
        |> Enum.split_with(&(&1 > 0))

      assert length(positive) > 1
      assert length(negative) > 1
    end

    test "ensure the vector points towards a playable direction" do
      coordinates =
        1..100
        |> Stream.map(fn _ -> Ball.new() end)
        |> Stream.flat_map(&[&1.vector_x, &1.vector_y])
        |> Enum.uniq()

      for coord <- coordinates do
        assert coord in [-0.8, -0.7, -0.6, -0.5, -0.4, 0.4, 0.5, 0.6, 0.7, 0.8]
      end
    end
  end

  describe "move/2" do
    test "updates the coordinates using the vector and the speed" do
      board = build(:board)
      ball = build(:ball, vector_x: 1, vector_y: -1, speed: 2)

      %{x: x, y: y} = Ball.move(ball, board)

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

      %{y: top_wall_ball_y} = Ball.move(top_wall_ball, board)
      %{x: right_wall_ball_x} = Ball.move(right_wall_ball, board)
      %{y: bottom_wall_ball_y} = Ball.move(bottom_wall_ball, board)
      %{x: left_wall_ball_x} = Ball.move(left_wall_ball, board)

      assert top_wall_ball_y == board.height - top_wall_ball.radius
      assert right_wall_ball_x == board.height - right_wall_ball.radius
      assert bottom_wall_ball_y == bottom_wall_ball.radius
      assert left_wall_ball_x == left_wall_ball.radius
    end

    test "updates the vector when colliding with the wall" do
      board = build(:board)
      # all balls are 1 unit away from their respective wall
      top_wall_ball =
        build(:ball, radius: 5, y: board.height - 6, vector_y: 1, speed: 10)

      right_wall_ball =
        build(:ball, radius: 5, x: board.width - 6, vector_x: 1, speed: 10)

      bottom_wall_ball = build(:ball, radius: 5, y: 6, vector_y: -1, speed: 10)
      left_wall_ball = build(:ball, radius: 5, x: 6, vector_x: -1, speed: 10)

      %{vector_y: top_wall_vector_y} = Ball.move(top_wall_ball, board)
      %{vector_x: right_wall_vector_x} = Ball.move(right_wall_ball, board)
      %{vector_y: bottom_wall_vector_y} = Ball.move(bottom_wall_ball, board)
      %{vector_x: left_wall_vector_x} = Ball.move(left_wall_ball, board)

      assert top_wall_vector_y == -top_wall_ball.vector_y
      assert right_wall_vector_x == -right_wall_ball.vector_x
      assert bottom_wall_vector_y == -bottom_wall_ball.vector_y
      assert left_wall_vector_x == -left_wall_ball.vector_x
    end
  end
end
