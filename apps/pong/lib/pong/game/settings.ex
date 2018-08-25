defmodule Pong.Game.Settings do
  defstruct [
    :board_width,
    :board_length,
    :ball_speed
  ]

  @type t :: %__MODULE__{}

  def new({width, length}, speed) do
    %__MODULE__{
      board_width: width,
      board_length: length,
      ball_speed: speed
    }
  end
end
