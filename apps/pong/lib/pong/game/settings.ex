defmodule Pong.Game.Settings do
  defstruct [
    :board_width,
    :board_length,
    :ball_speed
  ]

  alias __MODULE__

  import Pong.Config, only: [config!: 2]

  @type t :: %__MODULE__{}

  @spec new(integer(), integer()) :: Settings.t()
  def new(width, length) do
    %__MODULE__{
      board_width: width,
      board_length: length,
      ball_speed: config!(Pong, :ball_speed)
    }
  end
end
