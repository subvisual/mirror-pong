defmodule Pong.Engines.MultiTest do
  use ExUnit.Case
  doctest Pong.Engines.Multi

  alias Pong.Engines.Multi

  describe "add_player/1" do
    test "errors if the game is full" do
      assert {:error, :game_full} = Multi.add_player(300, 300)
    end

    test "adds the left player if no players have joined" do
      assert {:ok, :left, 1} = Multi.add_player(nil, nil)
    end

    test "adds the right player if there is a left player" do
      assert {:ok, :right, 1} = Multi.add_player(1, nil)
    end

    test "prioritizes adding the left player" do
      assert {:ok, :left, 2} = Multi.add_player(1, 1)
    end

    test "adds the right player if there are more left players" do
      assert {:ok, :right, 2} = Multi.add_player(5, 1)
    end
  end

  describe "remove_player/2" do
    test "decreases the correct player count" do
      assert {:ok, 2} = Multi.remove_player(:left, 3)
      assert {:ok, 2} = Multi.remove_player(:right, 3)
    end

    test "errors if the player hasn't joined" do
      assert {:error, :invalid_player} = Multi.remove_player(:left, nil)
    end
  end

  describe "players_ready?/0" do
    test "is true if there are players on both sides" do
      assert Multi.players_ready?(2, 1)
    end

    test "is false if there are less than two players" do
      refute Multi.players_ready?(1, 0)
      refute Multi.players_ready?(0, 1)
      refute Multi.players_ready?(1, nil)
      refute Multi.players_ready?(nil, 1)
    end
  end
end
