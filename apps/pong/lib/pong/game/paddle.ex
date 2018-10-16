defmodule Pong.Game.Paddle do
  defstruct [
    :width,
    :height,
    :x,
    :y,
    :speed,
    :fill,
    :movement
  ]

  import Pong.Config, only: [config!: 2]

  @default_speed 5

  @type t :: %__MODULE__{
          x: integer(),
          y: integer(),
          speed: integer(),
          width: integer(),
          height: integer(),
          fill: String.t()
        }

  @type default :: %__MODULE__{
          x: integer(),
          y: integer(),
          speed: 5,
          width: integer(),
          height: integer(),
          fill: String.t()
        }

  @type direction :: :up | :down

  @spec new(keyword()) :: t()
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

  @spec random_fills(integer()) :: [String.t()]
  def random_fills(n) do
    config!(__MODULE__, :fills)
    |> Enum.shuffle()
    |> Enum.take(n)
  end

  @spec random_fill :: String.t()
  def random_fill, do: random_fills(1) |> List.first()

  @spec apply_vector(t(), :up) :: t()
  def apply_vector(%__MODULE__{y: y} = paddle, :up),
    do: %{paddle | y: y + @default_speed, movement: 1}

  @spec apply_vector(t(), :down) :: t()
  def apply_vector(%__MODULE__{y: y} = paddle, :down),
    do: %{paddle | y: y - @default_speed, movement: -1}

  @spec apply_vector(t(), direction) :: t()
  def apply_vector(%__MODULE__{y: y} = paddle, _),
    do: %{paddle | y: y, movement: 0}

  @spec ensure_between(t(), integer(), integer()) :: t()
  def ensure_between(%__MODULE__{} = paddle, min, max) do
    clamped_y =
      paddle.y
      |> min(max - paddle.height / 2)
      |> max(min + paddle.height / 2)

    %{paddle | y: clamped_y}
  end
end
