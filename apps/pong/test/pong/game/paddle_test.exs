defmodule Pong.Game.PaddleTest do
  use ExUnit.Case
  doctest Pong.Game.Paddle

  alias Pong.Game.Paddle

  import Pong.Factory

  describe "new/1" do
    test "places the x coordinate according to the margin" do
      paddle = Paddle.new(y: 500)

      assert paddle.x == 35
    end

    test "places the x coordinate relative backwards to an offset" do
      paddle = Paddle.new(y: 500, relative_to: 1000)

      assert paddle.x == 965
    end
  end

  describe "move/3" do
    test "increments the y coordinate if moving up" do
      paddle = build(:paddle)
      board = build(:board)

      %{y: y} = Paddle.move(paddle, :up, board)

      assert y > paddle.y
    end

    test "decrements the y coordinate if moving down" do
      paddle = build(:paddle)
      board = build(:board)

      %{y: y} = Paddle.move(paddle, :down, board)

      assert y < paddle.y
    end

    test "prevents the paddle from overflowing off the game board" do
      board = build(:board)
      # position the paddle center 1 point below the board edge
      paddle = build(:paddle, height: 100, y: board.height - 51)

      %{y: y} = Paddle.move(paddle, :up, board)

      assert y == board.height - 50
    end
  end
end
