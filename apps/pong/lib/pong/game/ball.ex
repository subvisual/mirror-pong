defmodule Pong.Game.Ball do
  defstruct [
    :x,
    :y,
    :vector_x,
    :vector_y,
    :radius
  ]

  @type t :: %__MODULE__{}
  @type option :: :start_x | :start_y | :radius
  @type arg :: {option(), integer()}

  alias Pong.Game.{Ball, Settings}

  @spec new([arg()]) :: Ball.t()
  def new(args) do
    start_x = Keyword.fetch!(args, :start_x)
    start_y = Keyword.fetch!(args, :start_y)
    radius = Keyword.fetch!(args, :radius)

    # TODO: randomize initial vector

    %__MODULE__{
      radius: radius,
      x: start_x,
      y: start_y,
      vector_x: 0,
      vector_y: 0
    }
  end

  @spec move(Ball.t(), Settings.t()) :: Ball.t()
  def move(_ball, _settings) do
    {:error, :not_implemented}
  end
end
