defmodule Skeleton.SoftDelete.Config do
  def view_suffix, do: config(:view_suffix, "_without_deleted")
  def deleted_at_field_type, do: config(:deleted_at_field_type, :utc_datetime_usec)

  def config(key, default \\ nil) do
    Application.get_env(:skeleton_soft_delete, key, default)
  end
end
