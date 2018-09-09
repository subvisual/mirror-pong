use Mix.Config

config :pong, Pong, fps: 60

config :pong, Pong.Game.Ball,
  start_x: 250,
  start_y: 250,
  radius: 5

config :pong, Pong.Game.Paddle,
  start_x: 10,
  start_y: 250,
  width: 5,
  height: 20
