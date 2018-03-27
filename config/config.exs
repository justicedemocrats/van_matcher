# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :van_matcher,
  ecto_repos: [VanMatcher.Repo]

# Configures the endpoint
config :van_matcher, VanMatcher.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "jJbrwtcGVrJ7YvU9KrDMaH6Q6H5PYqE5vbtd8obOUqSy/r1wPxTlXPmuuY+QPC2o",
  render_errors: [view: VanMatcher.ErrorView, accepts: ~w(html json)],
  pubsub: [name: VanMatcher.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
