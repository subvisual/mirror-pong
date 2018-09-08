defmodule Pong.Game.Paddle do
  defstruct [
    :width,
    :length,
    :x,
    :y
  ]

  @type t :: %__MODULE__{}
  @type direction :: :up | :down
  @type option :: :width | :length
  @type arg :: {option(), integer()}

  alias __MODULE__

  @spec new([arg()]) :: Paddle.t()
  def new(args) do
    start_x = Keyword.fetch!(args, :start_x)
    start_y = Keyword.fetch!(args, :start_y)
    width = Keyword.fetch!(args, :width)
    length = Keyword.fetch!(args, :length)

    %__MODULE__{
      width: width,
      length: length,
      x: start_x,
      y: start_y
    }
  end

  @spec move(Paddle.t(), Paddle.direction()) :: Paddle.t()
  def move(_paddle, _direction) do
    {:error, :not_implemented}
  end
end
