defmodule Skeleton.App.User do
  use Skeleton.App, :schema

  schema soft_delete("users") do
    field :name, :string
    field :email, :string

    soft_delete_field()
    timestamps()
  end

  def with_deleted do
    {"users", Skeleton.App.User}
  end
end
