defmodule Pong.Engines.LimitedNumber do
  defmacro __using__(opts) do
    quote do
      use Pong.Engine

      @limit unquote(opts)[:limit]

      def add_player(nil, _, id), do: {:ok, :left, MapSet.new([id])}
      def add_player(_, nil, id), do: {:ok, :right, MapSet.new([id])}

      def add_player(left, right, id) do
        left_size = MapSet.size(left)
        right_size = MapSet.size(right)

        cond do
          left_size >= @limit and right_size >= @limit ->
            {:error, :game_full}

          left_size > right_size ->
            {:ok, :right, MapSet.put(right, id)}

          true ->
            {:ok, :left, MapSet.put(left, id)}
        end
      end

      def remove_player(_, nil),
        do: {:error, :invalid_player}

      def remove_player(id, set) do
        {:ok, MapSet.delete(set, id)}
      end

      def players_ready?(left, right) do
        left && MapSet.size(left) > 0 && right && MapSet.size(right) > 0
      end
    end
  end
end
