defmodule Pong.Config do
  def os_env(name) do
    System.get_env(name)
  end

  def os_env!(name) do
    case os_env(name) do
      nil -> raise "os env #{name} not set!"
      value -> value
    end
  end

  def config(mod, key, default \\ nil) do
    Application.get_env(:pong, mod, [])
    |> Keyword.get(key, default)
    |> parse_config_value()
  end

  def config!(mod, key) do
    Application.get_env(:pong, mod)
    |> Keyword.get(key)
    |> parse_config_value!()
  end

  defp parse_config_value({:system, var}), do: os_env(var)
  defp parse_config_value(value), do: value

  defp parse_config_value!({:system, var}), do: os_env!(var)
  defp parse_config_value!(value), do: value
end
