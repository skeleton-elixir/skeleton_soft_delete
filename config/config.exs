use Mix.Config

config :skeleton_soft_delete, ecto_repos: [Skeleton.App.Repo]

config :skeleton_soft_delete, Skeleton.App.Repo,
  adapter: Ecto.Adapters.Postgres,
  pool: Ecto.Adapters.SQL.Sandbox,
  hostname: System.get_env("POSTGRES_HOST", "localhost"),
  database: "skeleton_soft_delete_test",
  password: System.get_env("POSTGRES_PASSWORD", "123456"),
  username: System.get_env("POSTGRES_USERNAME", "postgres")

config :logger, :console, level: :error
