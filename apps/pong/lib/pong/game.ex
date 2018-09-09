defmodule Pong.Game do
  defstruct [
    :ball,
    :board,
    :paddle_left,
    :paddle_right
  ]

  alias __MODULE__
  alias Pong.Game.{Ball, Paddle, Board}

  import Pong.Config, only: [config!: 2]

  @type t :: %__MODULE__{}
  @type player_ref :: :left | :right

  @spec new(integer(), integer()) :: Game.t()
  def new(board_width, board_height) do
    paddle_margin = config!(Paddle, :start_x)

    %__MODULE__{
      ball: Ball.new(),
      board: Board.new(board_width, board_height),
      paddle_left: Paddle.new(paddle_margin),
      paddle_right: Paddle.new(board_width - paddle_margin)
    }
  end

  @doc """
  Applies the ball movement to the game.
  """
  @spec apply(Game.t()) :: Game.t()
  def apply(_game) do
    # 2 cycles: apply and then check for any collisions
    {:error, :not_implemented}
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
