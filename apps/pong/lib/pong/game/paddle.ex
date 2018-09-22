defmodule Pong.Game.Paddle do
  defstruct [
    :width,
    :height,
    :x,
    :y,
    :speed,
    :fill
  ]

  import Pong.Config, only: [config!: 2]

  @type t :: %__MODULE__{}
  @type direction :: :up | :down

  @default_speed 5

  alias __MODULE__
  alias Pong.Game.Board

  @spec new(keyword()) :: Paddle.t()
  def new(args) do
    height = config!(__MODULE__, :height)
    margin = config!(__MODULE__, :margin)
    width = config!(__MODULE__, :width)

    start_y = Keyword.fetch!(args, :y)

    start_x =
      case Keyword.get(args, :relative_to) do
        nil -> margin
        offset -> offset - margin
      end

    fill = Keyword.get(args, :fill, random_fill())

    %__MODULE__{
      width: width,
      height: height,
      x: start_x,
      y: start_y,
      fill: fill,
      speed: @default_speed
    }
  end

  @spec move(Paddle.t(), Paddle.direction(), Board.t()) :: Paddle.t()
  def move(paddle, direction, board) do
    paddle
    |> apply_vector(direction)
    |> prevent_overflow(board)
  end

  @spec random_fills(integer()) :: String.t()
  def random_fills(n) do
    config!(__MODULE__, :fills)
    |> Enum.shuffle()
    |> Enum.take(n)
  end

  @spec random_fill :: String.t()
  def random_fill, do: random_fills(1) |> List.first()

  defp apply_vector(%{y: y} = paddle, :up) do
    %{paddle | y: y + @default_speed}
  end

  defp apply_vector(%{y: y} = paddle, :down) do
    %{paddle | y: y - @default_speed}
  end

  defp prevent_overflow(paddle, board) do
    clamped_y =
      paddle.y
      |> min(board.height - paddle.height / 2)
      |> max(paddle.height / 2)

    %{paddle | y: clamped_y}
  end
end
