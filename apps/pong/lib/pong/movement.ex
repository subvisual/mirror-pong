defmodule Pong.Movement do
  alias Pong.Game

  alias Pong.Game.{
    Ball,
    Board,
    Paddle
  }

  alias Pong.Movement.Buffer

  @type event :: {String.t(), map()}

  @doc """
  Applies the buffer movements to the paddles and computes all new positions
  resulting of the ball movement and collisions.
  """
  @spec apply_to(Game.t(), Buffer.t()) :: {[event()], Game.t()}
  def apply_to(%Game{} = game, %Buffer{} = buffer) do
    game
    |> apply_movement(buffer)
    |> apply_score()
  end

  defp apply_movement(game, buffer) do
    %{
      ball: ball,
      board: board,
      paddle_left: paddle_left,
      paddle_right: paddle_right
    } = game

    movements = Buffer.events(buffer)

    updated_paddle_left =
      apply_paddle_movements(paddle_left, movements[:left], board)

    updated_paddle_right =
      apply_paddle_movements(paddle_right, movements[:right], board)

    updated_ball =
      Enum.reduce(1..ball.speed, ball, fn _, acc ->
        acc
        |> apply_ball_movement(board)
        |> apply_leftside_collision(updated_paddle_left)
        |> apply_rightside_collision(updated_paddle_right)
      end)

    %{
      game
      | ball: updated_ball,
        paddle_left: updated_paddle_left,
        paddle_right: updated_paddle_right
    }
  end

  defp apply_score(game) do
    cond do
      ball_passed_left_paddle?(game.ball, game.paddle_left) ->
        update_score(game, :right)

      ball_passed_right_paddle?(game.ball, game.paddle_right) ->
        update_score(game, :left)

      true ->
        {[], game}
    end
  end

  defp update_score(game, ref) do
    {event, updated_game} = Game.score(game, ref)

    payload = %{
      score_left: updated_game.score_left,
      score_right: updated_game.score_right
    }

    events =
      case event do
        :player_scored ->
          [{"player_scored", payload}]

        :game_over ->
          [{"player_scored", payload}, {"game_over", updated_game}]
      end

    {events, updated_game}
  end

  defp apply_paddle_movements(paddle, movements, board) do
    Enum.reduce(
      movements,
      paddle,
      &apply_paddle_movement(&2, &1, board)
    )
  end

  defp apply_paddle_movement(paddle, direction, board) do
    paddle
    |> Paddle.apply_vector(direction)
    |> Paddle.ensure_between(0, board.height)
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

  defp ball_passed_left_paddle?(ball, paddle) do
    rightmost_ball_x = ball.x + ball.radius
    leftmost_paddle_x = paddle.x - paddle.width / 2

    rightmost_ball_x < leftmost_paddle_x
  end

  defp ball_passed_right_paddle?(ball, paddle) do
    leftmost_ball_x = ball.x - ball.radius
    rightmost_paddle_x = paddle.x + paddle.width / 2

    leftmost_ball_x > rightmost_paddle_x
  end
end
