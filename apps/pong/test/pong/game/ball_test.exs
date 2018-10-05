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

  describe "ensure_between_height/3" do
    test "prevents the y coordinate from being over the max value" do
      ball = build(:ball, y: 10, radius: 1)

      updated_ball = Ball.ensure_between_height(ball, 0, 5)

      assert updated_ball.x == ball.x
      # center is at max - radius
      assert updated_ball.y == 4
    end

    test "prevents the y coordinate from being under the min value" do
      ball = build(:ball, y: 10, radius: 1)

      updated_ball = Ball.ensure_between_height(ball, 20, 30)

      assert updated_ball.x == ball.x
      # center is at min - radius
      assert updated_ball.y == 21
    end
  end

  describe "ensure_between_width/3" do
    test "prevents the x coordinate from being over the max value" do
      ball = build(:ball, x: 10, radius: 1)

      updated_ball = Ball.ensure_between_width(ball, 0, 5)

      assert updated_ball.y == ball.y
      # center is at max - radius
      assert updated_ball.x == 4
    end

    test "prevents the x coordinate from being under the min value" do
      ball = build(:ball, x: 10, radius: 1)

      updated_ball = Ball.ensure_between_width(ball, 20, 30)

      assert updated_ball.y == ball.y
      # center is at min - radius
      assert updated_ball.x == 21
    end
  end

  describe "reverse_vector_component/2" do
    test "reverses the corresponding vector component" do
      ball = build(:ball, vector_x: 1, vector_y: 1)

      updated_ball =
        ball
        |> Ball.reverse_vector_component(:x)
        |> Ball.reverse_vector_component(:y)

      assert updated_ball.vector_x == -ball.vector_x
      assert updated_ball.vector_y == -ball.vector_y
    end
  end
end
