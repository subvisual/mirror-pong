defmodule Pong.Game do
  defstruct [
    :ball,
    :board,
    :paddle_left,
    :paddle_right
  ]

  alias __MODULE__

  alias Pong.Game.{
    Ball,
    Board,
    Paddle
  }

  @type t :: %__MODULE__{}
  @type player_ref :: :left | :right

  @spec new :: Game.t()
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

  @doc """
  Applies the ball movement to the game.
  """
  @spec apply(Game.t()) :: Game.t()
  def apply(%{ball: ball, board: board} = game) do
    %{game | ball: Ball.move(ball, board)}
  end

  @doc """
  Applies movement to one of the paddles.
  """
  @spec move(Game.t(), player_ref(), Paddle.direction()) :: Game.t()
  def move(game, player_ref, direction) do
    paddle_ref = String.to_existing_atom("paddle_#{player_ref}")

    paddle =
      Map.get(game, paddle_ref)
      |> Paddle.move(direction, game.board)

    Map.put(game, paddle_ref, paddle)
  end
end
