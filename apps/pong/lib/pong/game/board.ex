defmodule Pong.Game.Board do
  defstruct [
    :width,
    :height
  ]

  alias __MODULE__

  @type t :: %__MODULE__{}

  @spec new(integer(), integer()) :: Board.t()
  def new(width, length) do
    %__MODULE__{
      width: width,
      height: length
    }
  end
end
