use Mix.Config

config :pong, Pong, fps: 60

config :pong, Pong.Game.Board,
  width: 1000,
  height: 1000

config :pong, Pong.Game.Ball,
  start_x: 250,
  start_y: 250,
  radius: 5

config :pong, Pong.Game.Paddle,
  width: 10,
  height: 100,
  margin: 30
