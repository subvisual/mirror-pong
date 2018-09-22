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
  def move(ball, board) do
    ball
    |> apply_vector()
    |> apply_collisions(board)
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

  defp apply_vector(ball) do
    %{
      ball
      | x: ball.x + ball.vector_x * ball.speed,
        y: ball.y + ball.vector_y * ball.speed
    }
  end

  defp apply_collisions(ball, board) do
    cond do
      collided_top_wall?(ball, board) or collided_bottom_wall?(ball) ->
        ball
        |> clamp_coordinate(:y, board)
        |> reverse_vector_component(:vector_y)

      collided_right_wall?(ball, board) or collided_left_wall?(ball) ->
        ball
        |> clamp_coordinate(:x, board)
        |> reverse_vector_component(:vector_x)

      true ->
        ball
    end
  end

  defp collided_top_wall?(ball, board),
    do: ball.y >= board.height - ball.radius

  defp collided_right_wall?(ball, board),
    do: ball.x >= board.width - ball.radius

  defp collided_left_wall?(ball), do: ball.x <= ball.radius

  defp collided_bottom_wall?(ball), do: ball.y <= ball.radius

  defp clamp_coordinate(ball, coordinate, board) do
    clamped_coordinate =
      ball
      |> Map.get(coordinate)
      |> min(board.height - ball.radius)
      |> max(ball.radius)

    Map.put(ball, coordinate, clamped_coordinate)
  end

  defp reverse_vector_component(ball, component) do
    Map.update!(ball, component, &(&1 * -1))
  end
end
