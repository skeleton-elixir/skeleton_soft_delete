defmodule Skeleton.SoftDelete.Migration do
  use Ecto.Migration
  import Skeleton.SoftDelete.Config

  def before_setup_soft_delete(table_name, singular_name) do
    create_or_replace_function()
    drop_view(table_name)
    drop_trigger(table_name, singular_name)
  end

  def after_setup_soft_delete(table_name, singular_name) do
    add_soft_delete_field(table_name)
    create_view(table_name)
    create_index(table_name)
    create_trigger(table_name, singular_name)
  end

  def delete_soft_delete(table_name, singular_name) do
    drop_trigger(table_name, singular_name)
    drop_view(table_name)
  end

  def delete_soft_delete_function do
    execute("""
      DROP FUNCTION IF EXISTS soft_delete();
    """)
  end

  def create_or_replace_function do
    execute("""
      CREATE OR REPLACE FUNCTION soft_delete() RETURNS trigger AS $$
        DECLARE
          command text := ' SET deleted_at = current_timestamp WHERE id = $1';
        BEGIN
          EXECUTE 'UPDATE ' || TG_TABLE_NAME || command USING OLD.id;
          RETURN OLD;
        END;
      $$ LANGUAGE plpgsql;
    """)
  end

  def add_soft_delete_field(table_name) do
    alter table(table_name) do
      add_if_not_exists(:deleted_at, :naive_datetime_usec)
    end
  end

  defp drop_view(table_name) do
    execute("""
      DROP VIEW IF EXISTS #{table_name}#{view_suffix()};
    """)
  end

  defp create_view(table_name) do
    execute("""
      CREATE VIEW #{table_name}#{view_suffix()} AS
      SELECT * FROM #{table_name} WHERE deleted_at IS NULL;
    """)
  end

  defp create_index(table_name) do
    create(index(table_name, [:deleted_at], where: "deleted_at IS NULL"))
  end

  defp create_trigger(table_name, singular_name) do
    execute("""
      CREATE TRIGGER soft_delete_#{singular_name}
      INSTEAD OF DELETE ON #{table_name}#{view_suffix()}
      FOR EACH ROW EXECUTE PROCEDURE soft_delete();
    """)
  end

  defp drop_trigger(table_name, singular_name) do
    execute("""
      DROP TRIGGER IF EXISTS soft_delete_#{singular_name}
      ON #{table_name}#{view_suffix()}
    """)
  end
end
