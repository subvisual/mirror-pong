defmodule Pong.Game.PaddleTest do
  use ExUnit.Case
  doctest Pong.Game.Paddle

  alias Pong.Game.Paddle

  import Pong.Factory

  describe "new/1" do
    test "places the x coordinate according to the margin" do
      paddle = Paddle.new(y: 500)

      assert paddle.x == 30
    end

    test "places the x coordinate relative backwards to an offset" do
      paddle = Paddle.new(y: 500, relative_to: 1000)

      assert paddle.x == 970
    end
  end

  describe "apply_vector/1" do
    test "uses a positive vector when moving up" do
      paddle = build(:paddle)

      updated_paddle = Paddle.apply_vector(paddle, :up)

      assert updated_paddle.x == paddle.x
      assert updated_paddle.y == paddle.y + 5
    end

    test "uses a negative vector when moving down" do
      paddle = build(:paddle)

      updated_paddle = Paddle.apply_vector(paddle, :down)

      assert updated_paddle.x == paddle.x
      assert updated_paddle.y == paddle.y - 5
    end
  end

  describe "ensure_between/3" do
    test "prevents the y coordinate from being over the max value" do
      paddle = build(:paddle, y: 10, height: 2)

      updated_paddle = Paddle.ensure_between(paddle, 0, 5)

      assert updated_paddle.x == paddle.x
      # center is at max - height / 2
      assert updated_paddle.y == 4
    end

    test "prevents the y coordinate from being under the min value" do
      paddle = build(:paddle, y: 10, height: 2)

      updated_paddle = Paddle.ensure_between(paddle, 20, 30)

      assert updated_paddle.x == paddle.x
      # center is at min - height / 2
      assert updated_paddle.y == 21
    end
  end
end
