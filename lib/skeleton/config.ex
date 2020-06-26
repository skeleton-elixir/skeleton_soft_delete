defmodule Skeleton.SoftDelete.Config do
  def table_suffix do
    config(:table_suffix, "_without_deleted")
  end

  def config(key, default \\ nil) do
    Application.get_env(:skeleton_soft_delete, key, default)
  end
end