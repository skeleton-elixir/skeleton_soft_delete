defmodule Skeleton.SoftDelete.SchemaTest do
  use Skeleton.SoftDelete.TestCase

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
