import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :object_detection, ObjectDetection.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "object_detection_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :object_detection, ObjectDetectionWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "RxcZHwVS3wccPcB0N/lXGkP8mp5Jy2xrqARQo7DsTxkuSh5QfrTNA6H2U4ySYZw4",
  server: false

# In test we don't send emails.
config :object_detection, ObjectDetection.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
