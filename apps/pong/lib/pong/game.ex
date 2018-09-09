defmodule Pong.Game do
  defstruct [
    :ball,
    :settings,
    :paddle_left,
    :paddle_right
  ]

  alias __MODULE__
  alias Pong.Game.{Ball, Paddle, Settings}

  @type t :: %__MODULE__{}
  @type player_ref :: :left | :right

  @spec new(integer(), integer()) :: Game.t()
  def new(board_width, board_height) do
    %__MODULE__{
      ball: Ball.new(),
      settings: Settings.new(board_width, board_height),
      paddle_left: Paddle.new(),
      paddle_right: Paddle.new()
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
  def move(_game, _player, _direction) do
    {:error, :not_implemented}
  end
end
