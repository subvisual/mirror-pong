use Mix.Config

config :client,
  namespace: Client,
  ecto_repos: [Client.Repo]

config :client, ClientWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base:
    "a35Dprco5Xrme3zE2vuQSwmocRV/eRt/zVOXOX/mKsgF195BHO1a0MGwWoE+ecah",
  render_errors: [view: ClientWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Client.PubSub, adapter: Phoenix.PubSub.PG2]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :logger, level: :warn

import_config "#{Mix.env()}.exs"
