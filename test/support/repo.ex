defmodule Skeleton.App.Repo do
  use Ecto.Repo, otp_app: :skeleton_soft_delete, adapter: Ecto.Adapters.Postgres
end