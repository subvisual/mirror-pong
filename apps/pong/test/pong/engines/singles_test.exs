defmodule Pong.Engines.SinglesTest do
  use ExUnit.Case
  doctest Pong.Engines.Singles

  alias Pong.Engines.Singles

  describe "add_player/1" do
    test "errors if the game is full" do
      assert {:error, :game_full} = Singles.add_player(true, true)
    end

    test "adds the left player if no players have joined" do
      assert {:ok, :left, true} = Singles.add_player(nil, nil)
    end

    test "adds the right player if there is a left player" do
      assert {:ok, :right, true} = Singles.add_player(true, nil)
    end
  end

  describe "remove_player/2" do
    test "removes the player if it has joined" do
      assert {:ok, nil} = Singles.remove_player(:left, true)
      assert {:ok, nil} = Singles.remove_player(:right, true)
    end

    test "errors if the player hasn't joined" do
      assert {:error, :invalid_player} = Singles.remove_player(:left, nil)
    end
  end

  describe "players_ready?/0" do
    test "is true if there are two players" do
      assert Singles.players_ready?(true, true)
    end

    test "is false if there are less than two players" do
      refute Singles.players_ready?(true, nil)
      refute Singles.players_ready?(nil, true)
    end
  end
end
