defmodule Pong.Game do
  defstruct [
    :ball,
    :board,
    :paddle_left,
    :paddle_right
  ]

  alias Pong.Movement

  alias Pong.Game.{
    Ball,
    Board,
    Paddle
  }

  @type t :: %__MODULE__{}
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

  # TODO: This will be moved to the apply cycle within Pong.Movement when we
  # are able to buffer and fold similar actions between consecutive applies
  @spec move(t(), player_ref(), Paddle.direction()) :: t()
  def move(%__MODULE__{} = game, player_ref, direction) do
    paddle_ref = String.to_existing_atom("paddle_#{player_ref}")

    paddle =
      Map.get(game, paddle_ref)
      |> Movement.apply_to(direction, game.board)

    Map.put(game, paddle_ref, paddle)
  end
end
