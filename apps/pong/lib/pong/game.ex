defmodule Pong.Game do
  defstruct [
    :ball,
    :board,
    :paddle_left,
    :paddle_right,
    :score_left,
    :score_right,
    :score_limit
  ]

  alias Pong.Game.{
    Ball,
    Board,
    Paddle
  }

  import Pong.Config, only: [config!: 2]

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

    score_limit = config!(__MODULE__, :score_limit)

    %__MODULE__{
      ball: Ball.new(),
      board: board,
      score_left: 0,
      score_right: 0,
      score_limit: score_limit,
      paddle_left: Paddle.new(y: board.height / 2, fill: left_paddle_fill),
      paddle_right:
        Paddle.new(
          y: board.height / 2,
          relative_to: board.width,
          fill: right_paddle_fill
        )
    }
  end

  @spec score(t(), player_ref()) :: {:game_over | :player_scored, t()}
  def score(%__MODULE__{} = game, ref) do
    score_ref = String.to_existing_atom("score_#{ref}")

    game
    |> Map.update(score_ref, 1, &(&1 + 1))
    |> reset_game_positions()
  end

  defp reset_game_positions(game) do
    if game_over?(game) do
      {:game_over, game}
    else
      new_game = %{
        new()
        | score_left: game.score_left,
          score_right: game.score_right
      }

      {:player_scored, new_game}
    end
  end

  defp game_over?(game) do
    game.score_limit == game.score_left or game.score_limit == game.score_right
  end
end
