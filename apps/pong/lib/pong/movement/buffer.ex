defmodule Pong.Movement.Buffer do
  defstruct left: %{up: 0, down: 0},
            right: %{up: 0, down: 0}

  @type counter :: %{
          up: integer(),
          down: integer()
        }

  @type t :: %__MODULE__{
          left: counter(),
          right: counter()
        }

  @type default :: %__MODULE__{
          left: %{up: 0, down: 0},
          right: %{up: 0, down: 0}
        }

  @type tag :: :left | :right
  @type event :: :up | :down

  @spec new :: default()
  def new do
    %__MODULE__{}
  end

  @spec add(t(), tag(), event()) :: t()
  def add(%__MODULE__{} = buffer, tag, event) do
    Map.update!(buffer, tag, fn events ->
      Map.update!(events, event, &(&1 + 1))
    end)
  end

  @spec events(t()) :: %{left: list(event()), right: list(event())}
  def events(%__MODULE__{} = buffer) do
    %{
      left: fold_events(buffer.left),
      right: fold_events(buffer.right)
    }
  end

  defp fold_events(%{up: up, down: down}),
    do: cycle_events(up - down)

  defp cycle_events(n) when n > 0, do: for(_ <- 1..n, do: :up)
  defp cycle_events(n) when n < 0, do: for(_ <- 1..-n, do: :down)
  defp cycle_events(_), do: []
end
