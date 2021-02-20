defmodule Skeleton.SoftDelete.Migration do
  use Ecto.Migration
  import Skeleton.SoftDelete.Config

  def before_setup_soft_delete(table_name, singular_name, prefix \\ "public") do
    create_or_replace_function()
    drop_view(prefix, table_name)
    drop_trigger(prefix, table_name, singular_name)
  end

  def soft_delete() do
    add(:deleted_at, :naive_datetime_usec)
  end

  def after_setup_soft_delete(table_name, singular_name, prefix \\ "public") do
    create_view(prefix, table_name)
    create_index(prefix, table_name)
    create_trigger(prefix, table_name, singular_name)
  end

  def delete_soft_delete(table_name, singular_name, prefix \\ "public") do
    drop_trigger(prefix, table_name, singular_name)
    drop_view(prefix, table_name)
  end

  def delete_soft_delete_function do
    execute("""
      DROP FUNCTION IF EXISTS public.soft_delete();
    """)
  end

  def create_or_replace_function do
    execute("""
      CREATE OR REPLACE FUNCTION public.soft_delete() RETURNS trigger AS $$
        DECLARE
          command text := ' SET deleted_at = current_timestamp WHERE id = $1';
        BEGIN
          EXECUTE 'UPDATE "' || TG_TABLE_SCHEMA || '"."' || TG_TABLE_NAME || '"' || command USING OLD.id;
          RETURN OLD;
        END;
      $$ LANGUAGE plpgsql;
    """)
  end

  defp drop_view(prefix, table_name) do
    execute("""
      DROP VIEW IF EXISTS "#{prefix}"."#{table_name}#{view_suffix()}";
    """)
  end

  defp create_view(prefix, table_name) do
    execute("""
      CREATE VIEW "#{prefix}"."#{table_name}#{view_suffix()}" AS
      SELECT * FROM "#{prefix}"."#{table_name}" WHERE deleted_at IS NULL;
    """)
  end

  defp create_index(prefix, table_name) do
    create_if_not_exists(
      index(table_name, [:deleted_at], prefix: prefix, where: "deleted_at IS NULL")
    )
  end

  defp create_trigger(prefix, table_name, singular_name) do
    execute("""
      CREATE TRIGGER soft_delete_#{singular_name}
      INSTEAD OF DELETE ON "#{prefix}"."#{table_name}#{view_suffix()}"
      FOR EACH ROW EXECUTE PROCEDURE public.soft_delete();
    """)
  end

  defp drop_trigger(prefix, table_name, singular_name) do
    execute("""
      DROP TRIGGER IF EXISTS soft_delete_#{singular_name}
      ON "#{prefix}"."#{table_name}#{view_suffix()}"
    """)
  end
end
