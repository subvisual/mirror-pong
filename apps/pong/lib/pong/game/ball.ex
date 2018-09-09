defmodule Pong.Game.Ball do
  defstruct [
    :x,
    :y,
    :vector_x,
    :vector_y,
    :radius,
    :speed
  ]

  # TODO: Make this parameter increase with time
  @default_speed 5

  @type t :: %__MODULE__{}

  import Pong.Config, only: [config!: 2]

  alias Pong.Game.{Ball, Board}

  @spec new() :: Ball.t()
  def new do
    start_x = config!(__MODULE__, :start_x)
    start_y = config!(__MODULE__, :start_y)
    radius = config!(__MODULE__, :radius)

    {vector_x, vector_y} = generate_random_vector()

    %__MODULE__{
      radius: radius,
      x: start_x,
      y: start_y,
      vector_x: vector_x,
      vector_y: vector_y,
      speed: @default_speed
    }
  end

  @spec move(Ball.t(), Board.t()) :: Ball.t()
  def move(_ball, _board) do
    {:error, :not_implemented}
  end

  defp generate_random_vector do
    Stream.repeatedly(fn ->
      {random_vector_component(), random_vector_component()}
    end)
    |> Enum.find(fn
      {0, y} when y in [-1, 1] -> false
      _ -> true
    end)
  end

  defp random_vector_component do
    :rand.uniform(2) - 1
  end
end
