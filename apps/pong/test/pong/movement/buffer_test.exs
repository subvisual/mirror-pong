defmodule Pong.Movement.BufferTest do
  use ExUnit.Case
  doctest Pong.Movement.Buffer

  alias Pong.Movement.Buffer

  describe "add/1" do
    test "updates the corresponding tag and events" do
      buffer = Buffer.new()

      updated_buffer =
        buffer
        |> Buffer.add(:left, :up)
        |> Buffer.add(:right, :down)

      assert %Buffer{
               left: %{up: 1, down: 0},
               right: %{up: 0, down: 1}
             } = updated_buffer
    end
  end

  describe "events/1" do
    test "folds all actions into a list" do
      buffer = %Buffer{
        left: %{down: 2, up: 1},
        right: %{down: 3, up: 3}
      }

      assert %{
               left: [:down],
               right: []
             } = Buffer.events(buffer)
    end
  end
end
