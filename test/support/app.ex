defmodule Skeleton.App do
  def schema do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      import Skeleton.SoftDelete.Schema

      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id
      @timestamps_opts [type: :naive_datetime_usec]
    end
  end

  def migration do
    quote do
      use Ecto.Migration
      import Skeleton.SoftDelete.Migration
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
