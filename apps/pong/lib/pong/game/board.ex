defmodule Pong.Game.Board do
  defstruct [
    :width,
    :height
  ]

  alias __MODULE__

  import Pong.Config, only: [config!: 2]

  @type t :: %__MODULE__{}

  @spec new :: Board.t()
  def new do
    %__MODULE__{
      width: config!(Pong.Game.Board, :width),
      height: config!(Pong.Game.Board, :height)
    }
  end
end
