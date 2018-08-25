defmodule Pong.Game do
  defstruct [
    :settings,
    :paddle,
    :ball
  ]

  alias __MODULE__
  alias Pong.Game.{Ball, Paddle, Settings}

  @type t :: %__MODULE__{}
  @type player_ref :: :left | :right

  def new(opts) do
    board = Keyword.fetch!(opts, :board)
    speed = Keyword.fetch!(opts, :speed)
    settings = Settings.new(board, speed)
    ball = Keyword.fetch!(opts, :ball) |> Ball.new()
    paddle_left = Keyword.fetch!(opts, :paddle) |> Paddle.new()
    paddle_right = Keyword.fetch!(opts, :paddle) |> Paddle.new()

    %__MODULE__{
      ball: ball,
      settings: settings,
      paddle_left: paddle_left,
      paddle_right: paddle_right
    }
  end

  @doc """
  Applies the ball movement to the game.
  """
  @spec apply(Game.t()) :: Game.t()
  def apply(game) do
    # 2 cycles: apply and then check for any collisions
    {:error, :not_implemented}
  end

  @doc """
  Applies movement to one of the paddles.
  """
  @spec move(Game.t(), player_ref(), Paddle.direction()) :: Game.t()
  def move(game, player, direction) do
    {:error, :not_implemented}
  end
end
