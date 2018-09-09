defmodule Pong.Game.Paddle do
  defstruct [
    :width,
    :height,
    :x,
    :y
  ]

  import Pong.Config, only: [config!: 2]

  @type t :: %__MODULE__{}
  @type direction :: :up | :down

  alias __MODULE__
  alias Pong.Game.Settings

  @spec new() :: Paddle.t()
  def new do
    start_x = config!(__MODULE__, :start_x)
    start_y = config!(__MODULE__, :start_y)
    height = config!(__MODULE__, :height)
    width = config!(__MODULE__, :width)

    %__MODULE__{
      width: width,
      height: height,
      x: start_x,
      y: start_y
    }
  end

  @spec move(Paddle.t(), Paddle.direction(), Settings.t()) :: Paddle.t()
  def move(_paddle, _direction, _settings) do
    {:error, :not_implemented}
  end
end
