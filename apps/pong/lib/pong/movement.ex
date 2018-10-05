defmodule Pong.Movement do
  alias Pong.Game

  alias Pong.Game.{
    Ball,
    Board,
    Paddle
  }

  @doc """
  Applies movement to one of the paddles.
  """
  @spec apply_to(Paddle.t(), Paddle.direction(), Board.t()) :: Paddle.t()
  def apply_to(%Paddle{} = paddle, direction, %Board{} = board) do
    paddle
    |> Paddle.apply_vector(direction)
    |> Paddle.ensure_between(0, board.height)
  end

  @doc """
  Applies movement to the whole game.
  """
  @spec apply_to(Game.t()) :: Game.t()
  def apply_to(%Game{} = game) do
    %{
      ball: ball,
      board: board,
      paddle_left: paddle_left,
      paddle_right: paddle_right
    } = game

    moved_ball =
      ball
      |> apply_ball_movement(board)
      |> apply_leftside_collision(paddle_left)
      |> apply_rightside_collision(paddle_right)

    %{game | ball: moved_ball}
  end

  defp apply_ball_movement(%Ball{} = ball, %Board{} = board) do
    ball
    |> Ball.apply_vector()
    |> Ball.ensure_between_height(0, board.height)
    |> Ball.ensure_between_width(0, board.width)
    |> apply_board_collision(board)
  end

  defp apply_board_collision(ball, board) do
    cond do
      ball_in_board_height_limits?(ball, board) ->
        Ball.reverse_vector_component(ball, :y)

      ball_in_board_width_limits?(ball, board) ->
        Ball.reverse_vector_component(ball, :x)

      true ->
        ball
    end
  end

  defp apply_leftside_collision(ball, paddle) do
    if ball_collided_leftside?(ball, paddle) do
      Ball.reverse_vector_component(ball, :x)
    else
      ball
    end
  end

  defp apply_rightside_collision(ball, paddle) do
    if ball_collided_rightside?(ball, paddle) do
      Ball.reverse_vector_component(ball, :x)
    else
      ball
    end
  end

  defp ball_collided_leftside?(ball, paddle) do
    ball.x - ball.radius <= paddle.x and ball.y <= paddle.y + paddle.height / 2 and
      ball.y >= paddle.y - paddle.height / 2
  end

  defp ball_collided_rightside?(ball, paddle) do
    ball.x + ball.radius >= paddle.x and ball.y <= paddle.y + paddle.height / 2 and
      ball.y >= paddle.y - paddle.height / 2
  end

  defp ball_in_board_height_limits?(ball, board) do
    upper_limit = ball.y + ball.radius
    lower_limit = ball.y - ball.radius

    upper_limit >= board.height or lower_limit <= 0
  end

  defp ball_in_board_width_limits?(ball, board) do
    right_limit = ball.x + ball.radius
    left_limit = ball.x - ball.radius

    right_limit >= board.width or left_limit <= 0
  end
end
