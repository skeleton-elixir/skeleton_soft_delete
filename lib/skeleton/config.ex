defmodule Skeleton.SoftDelete.Config do
  def view_suffix do
    config(:view_suffix, "_without_deleted")
  end

  def config(key, default \\ nil) do
    Application.get_env(:skeleton_soft_delete, key, default)
  end
end