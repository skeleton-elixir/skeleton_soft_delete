defmodule Skeleton.SoftDelete.MigrationTest do
  use Skeleton.App.TestCase
  alias Skeleton.App.User

  describe "checks" do
    test "if soft_delete function exists" do
      query = "SELECT EXISTS(SELECT * FROM pg_proc WHERE proname = 'soft_delete')"

      assert %{rows: [[true]]} = SQL.query!(Repo, query, [])
    end

    test "if deleted_at column exists" do
      query = """
        SELECT column_name
        FROM information_schema.columns
        WHERE table_name='users' and column_name='deleted_at';
      """

      assert %{rows: [["deleted_at"]]} = SQL.query!(Repo, query, [])
    end

    test "if view exists" do
      query = """
        SELECT EXISTS (
          SELECT FROM information_schema.tables
          WHERE table_schema = 'public'
          AND table_name  = 'users_without_deleted'
        );
      """

      assert %{rows: [[true]]} = SQL.query!(Repo, query, [])
    end

    test "if trigger exists" do
      query = """
        SELECT tgname
        FROM pg_trigger
        WHERE NOT tgisinternal
        AND tgrelid = 'users_without_deleted'::regclass;
      """

      assert %{rows: [["soft_delete_user"]]} = SQL.query!(Repo, query, [])
    end
  end

  describe "deleting user" do
    test "mark as deleted" do
      {:ok, user} =
        %User{
          name: "Jon",
          email: "jon@example.com"
        }
        |> change()
        |> Repo.insert()

      Repo.delete(user)

      refute Repo.get(User, user.id)

      user = Repo.get(User.with_deleted, user.id)
      assert user.deleted_at
    end
  end
end
