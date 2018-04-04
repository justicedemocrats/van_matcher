use Mix.Config

config :van_matcher, VanMatcher.Endpoint,
  http: [:inet6, port: {:system, "PORT"}],
  url: [host: "example.com", port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true

# Do not print debug messages in production
config :logger, level: :info

config :van_matcher, VanMatcher.Mailer,
  adapter: Swoosh.Adapters.Mailgun,
  api_key: "${MAILGUN_API_KEY}",
  domain: "${MAILGUN_DOMAIN}"

config :van_matcher, secret: "${SECRET}"
