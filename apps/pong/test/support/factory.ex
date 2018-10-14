defmodule Pong.Factory do
  alias Pong.Game
  alias Pong.Movement

  alias Pong.Game.{
    Ball,
    Board,
    Paddle
  }

  use ExMachina

  def game_factory do
    %Game{
      ball: build(:ball),
      board: build(:board),
      paddle_left: build(:left_paddle),
      paddle_right: build(:right_paddle),
      score_left: 0,
      score_right: 0,
      score_limit: 3
    }
  end

  def left_paddle_factory do
    %Paddle{
      width: 10,
      height: 100,
      y: 500,
      x: 35
    }
  end

  def right_paddle_factory do
    %Paddle{
      width: 10,
      height: 100,
      y: 500,
      x: 965
    }
  end

  def paddle_factory do
    %Paddle{
      width: 10,
      height: 100,
      y: 500,
      x: 35
    }
  end

  def ball_factory do
    %Ball{
      radius: 5,
      speed: 5,
      x: 500,
      y: 500,
      vector_x: 5,
      vector_y: 5
    }
  end

  def board_factory do
    %Board{
      width: 1000,
      height: 1000
    }
  end

  def movement_buffer_factory do
    %Movement.Buffer{
      left: %{
        up: 0,
        down: 0
      },
      right: %{
        up: 0,
        down: 0
      }
    }
  end
end
