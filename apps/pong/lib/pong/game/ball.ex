defmodule Pong.Game.Ball do
  defstruct [
    :x,
    :y,
    :vector_x,
    :vector_y,
    :radius,
    :speed
  ]

  @default_speed 5
  @min_vector_value 4
  @max_vector_value 8

  @type t :: %__MODULE__{}

  import Pong.Config, only: [config!: 2]

  @spec new() :: t()
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

  @spec apply_vector(t()) :: t()
  def apply_vector(%__MODULE__{} = ball) do
    %{
      ball
      | x: ball.x + ball.vector_x,
        y: ball.y + ball.vector_y
    }
  end

  @spec ensure_between_height(t(), integer(), integer()) :: t()
  def ensure_between_height(%__MODULE__{} = ball, min, max),
    do: clamp_coordinate(ball, :y, min, max)

  @spec ensure_between_width(t(), integer(), integer()) :: t()
  def ensure_between_width(%__MODULE__{} = ball, min, max),
    do: clamp_coordinate(ball, :x, min, max)

  @spec reverse_vector_component(t(), :x | :y) :: t()
  def reverse_vector_component(%__MODULE__{} = ball, component) do
    vector_component = String.to_existing_atom("vector_#{component}")

    Map.update!(ball, vector_component, &(&1 * -1))
  end

  defp generate_random_vector do
    {vector_x, vector_y} =
      {random_vector_component(), random_vector_component()}

    {random_sign(vector_x), random_sign(vector_y)}
  end

  # generate a vector number from the pool of [0.4, 0.5, 0.6, 0.7, 0.8]
  defp random_vector_component do
    min = @min_vector_value - 1
    max = @max_vector_value - min

    (min + :rand.uniform(max)) / 10
  end

  # attribute a random sign (+ or -) to a vector component
  defp random_sign(vector_component) do
    [-1, 1]
    |> Enum.shuffle()
    |> List.first()
    |> Kernel.*(vector_component)
  end

  defp clamp_coordinate(ball, coordinate, min, max) do
    clamped_coordinate =
      ball
      |> Map.get(coordinate)
      |> min(max - ball.radius)
      |> max(min + ball.radius)

    Map.put(ball, coordinate, clamped_coordinate)
  end
end
