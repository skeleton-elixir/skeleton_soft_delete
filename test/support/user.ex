defmodule Skeleton.SoftDelete.User do
  use Skeleton.SoftDelete.App, :schema

  schema soft_delete("users") do
    field :name, :string
    field :email, :string

    soft_delete_field()
    timestamps()
  end

  def with_deleted do
    {"users", Skeleton.SoftDelete.User}
  end
end