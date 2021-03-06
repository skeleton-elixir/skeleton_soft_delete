defmodule Skeleton.SoftDelete.Schema do
  import Skeleton.SoftDelete.Config

  defmacro soft_delete_field() do
    quote do
      Ecto.Schema.field(:deleted_at, deleted_at_field_type())
    end
  end

  defmacro __using__(_) do
    quote do
      import Skeleton.SoftDelete.Schema
    end
  end

  def soft_delete(table_name) do
    "#{table_name}#{view_suffix()}"
  end
end
