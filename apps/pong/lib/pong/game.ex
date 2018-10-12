defmodule Pong.Game do
  defstruct [
    :ball,
    :board,
    :paddle_left,
    :paddle_right
  ]

  alias Pong.Game.{
    Ball,
    Board,
    Paddle
  }

  @type t :: %__MODULE__{
          ball: Ball.t(),
          board: Board.t(),
          paddle_left: Paddle.t(),
          paddle_right: Paddle.t()
        }

  @type player_ref :: :left | :right

  @spec new :: t()
  def new do
    board = Board.new()

    [left_paddle_fill, right_paddle_fill] = Paddle.random_fills(2)

    %__MODULE__{
      ball: Ball.new(),
      board: board,
      paddle_left: Paddle.new(y: board.height / 2, fill: left_paddle_fill),
      paddle_right:
        Paddle.new(
          y: board.height / 2,
          relative_to: board.width,
          fill: right_paddle_fill
        )
    }
  end
end
