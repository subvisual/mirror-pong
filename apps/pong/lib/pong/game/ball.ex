defmodule Pong.Game.Ball do
  defstruct [
    :x,
    :y,
    :vector_x,
    :vector_y,
    :radius
  ]

  @type t :: %Ball{}

  alias Pong.Game.{Ball, Settings}

  # TODO: receive the start (x, y) position
  def new(radius) do
    %__MODULE__{
      radius: radius,
      x: 0,
      y: 0,
      vector_x: 0,
      vector_y: 0
    }
  end

  @spec move(Ball.t(), Settings.t()) :: Ball.t()
  def move(ball, settings) do
    {:error, :not_implemented}
  end
end
