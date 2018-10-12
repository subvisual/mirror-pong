defmodule Pong.Game do
  defstruct [
    :ball,
    :board,
    :paddle_left,
    :paddle_right,
    :score_left,
    :score_right
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
          paddle_right: Paddle.t(),
          score_left: integer(),
          score_right: integer()
        }

  @type default :: %__MODULE__{
          ball: Ball.t(),
          board: Board.t(),
          paddle_left: Paddle.t(),
          paddle_right: Paddle.t(),
          score_left: 0,
          score_right: 0
        }

  @type player_ref :: :left | :right

  @spec new :: default()
  def new do
    board = Board.new()

    [left_paddle_fill, right_paddle_fill] = Paddle.random_fills(2)

    %__MODULE__{
      ball: Ball.new(),
      board: board,
      score_left: 0,
      score_right: 0,
      paddle_left: Paddle.new(y: board.height / 2, fill: left_paddle_fill),
      paddle_right:
        Paddle.new(
          y: board.height / 2,
          relative_to: board.width,
          fill: right_paddle_fill
        )
    }
  end

  @spec score(t(), player_ref()) :: t()
  def score(%__MODULE__{} = game, ref) do
    score_ref = String.to_existing_atom("score_#{ref}")

    game
    |> Map.update(score_ref, 1, &(&1 + 1))
    |> reset()
  end

  defp reset(game) do
    new_game = new()

    %{new_game | score_left: game.score_left, score_right: game.score_right}
  end
end
