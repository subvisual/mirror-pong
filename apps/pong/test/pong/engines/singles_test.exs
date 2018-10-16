defmodule Pong.Engines.SinglesTest do
  use ExUnit.Case
  doctest Pong.Engines.Singles

  alias Pong.Engines.Singles

  describe "add_player/1" do
    test "errors if the game is full" do
      assert {:error, :game_full} = Singles.add_player(1, 1)
    end

    test "adds the left player if no players have joined" do
      assert {:ok, :left, 1} = Singles.add_player(nil, nil)
    end

    test "adds the right player if there is a left player" do
      assert {:ok, :right, 1} = Singles.add_player(true, nil)
    end
  end

  describe "remove_player/2" do
    test "removes the player if it has joined" do
      assert {:ok, 0} = Singles.remove_player(:left, 1)
      assert {:ok, 0} = Singles.remove_player(:right, 1)
    end

    test "errors if the player hasn't joined" do
      assert {:error, :invalid_player} = Singles.remove_player(:left, nil)
      assert {:error, :invalid_player} = Singles.remove_player(:left, 0)
    end
  end

  describe "players_ready?/0" do
    test "is true if there are two players" do
      assert Singles.players_ready?(1, 1)
    end

    test "is false if there are less than two players" do
      refute Singles.players_ready?(1, nil)
      refute Singles.players_ready?(nil, 1)
      refute Singles.players_ready?(1, 0)
      refute Singles.players_ready?(0, 1)
    end
  end
end
