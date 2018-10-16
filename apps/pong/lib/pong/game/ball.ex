defmodule Pong.Game.Ball do
  defstruct [
    :x,
    :y,
    :vector_x,
    :vector_y,
    :radius,
    :speed,
    :spin
  ]

  @default_speed 2
  @default_spin 0
  @min_vector_value 4
  @max_vector_value 8

  @type t :: %__MODULE__{
          x: integer(),
          y: integer(),
          vector_x: float(),
          vector_y: float(),
          radius: integer(),
          speed: integer()
        }

  import Pong.Config, only: [config!: 2, config: 3]

  @spec new() :: t()
  def new do
    start_x = config!(__MODULE__, :start_x)
    start_y = config!(__MODULE__, :start_y)
    radius = config!(__MODULE__, :radius)
    speed = config(__MODULE__, :speed, @default_speed)

    {vector_x, vector_y} = generate_random_vector()

    %__MODULE__{
      radius: radius,
      x: start_x,
      y: start_y,
      vector_x: vector_x,
      vector_y: vector_y,
      speed: @default_speed,
      spin: @default_spin
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

  def add_spin(ball, direction) do
    cond do
      ball_has_same_direction?(ball, direction) ->
        %{ball | spin: 1}

      ball_has_opposite_direction?(ball, direction) ->
        %{ball | spin: -1}

      true ->
        ball
    end
  end

  def apply_spin(ball, 1) do
    # spin up reduces the y movement and increases the speed
    updated_vector_y = ball.vector_y - random_vector_change()
    updated_speed = ball.speed + 1
    %{ball | spin: 0, vector_y: updated_vector_y, speed: updated_speed}
  end

  def apply_spin(ball, -1) do
    # spin down increases the y movement and reduces the speed
    updated_vector_y = ball.vector_y + random_vector_change()
    updated_speed = ball.speed - 1
    %{ball | spin: 0, vector_y: updated_vector_y, speed: updated_speed}
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

  defp ball_has_same_direction?(ball, direction) do
    (ball.vector_y > 0 and direction > 0) or
      (ball.vector_y < 0 and direction < 0)
  end

  defp ball_has_opposite_direction?(ball, direction) do
    (ball.vector_y > 0 and direction < 0) or
      (ball.vector_y < 0 and direction > 0)
  end

  defp random_vector_change,
    do: Enum.random([0.15, 0.2, 0.25, 0.3])
end
