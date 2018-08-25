defmodule Pong.Game.Paddle do
  defstruct [
    :width,
    :length,
    :x,
    :y
  ]

  @type t :: %__MODULE__{}
  @type direction :: :up | :down

  alias __MODULE__
  alias Pong.Game.Settings

  # TODO: receive the start positions
  def new({width, length}) do
    %__MODULE__{
      width: width,
      length: length,
      x: 0,
      y: 0
    }
  end

  @spec move(Paddle.t(), Paddle.direction()) :: Paddle.t()
  def move(paddle, direction) do
    {:error, :not_implemented}
  end
end
