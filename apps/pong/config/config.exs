use Mix.Config

config :pong, Pong,
  fps: 60,
  start_delay: 3_000

config :pong, Pong.Game, score_limit: 5

config :pong, Pong.Game.Board,
  width: 1000,
  height: 1000

config :pong, Pong.Game.Ball,
  start_x: 500,
  start_y: 500,
  radius: 7,
  speed: 5

config :pong, Pong.Game.Paddle,
  width: 15,
  height: 120,
  margin: 30,
  fills: [
    # anakiwa (cyan)
    "#8BE9FD",
    # screamin green
    "#50FA7B",
    # koromiko (orange)
    "#FFB86C",
    # hot pink
    "#FF79C6",
    # perfume (purple)
    "#BD93F9",
    # persimmon (red)
    "#FF5555"
  ]

import_config "#{Mix.env()}.exs"
