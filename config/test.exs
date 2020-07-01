use Mix.Config

config :skeleton_soft_delete, ecto_repos: [Skeleton.App.Repo]

config :skeleton_soft_delete, Skeleton.App.Repo,
  adapter: Ecto.Adapters.Postgres,
  pool: Ecto.Adapters.SQL.Sandbox,
  database: "skeleton_soft_delete_test",
  username: System.get_env("SKELETON_SOFT_DELETE_DB_USER") || System.get_env("USER") || "postgres"

config :logger, :console, level: :error
config :logger, :console, level: :error