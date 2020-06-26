defmodule Skeleton.SoftDelete.TestCase do
  use ExUnit.CaseTemplate

  using opts do
    quote do
      use ExUnit.Case, unquote(opts)
      import Ecto.Query
      import Ecto.Changeset
      alias Ecto.Adapters.SQL
      alias Skeleton.SoftDelete.{Repo, User}
    end
  end

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Skeleton.SoftDelete.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Skeleton.SoftDelete.Repo, {:shared, self()})
  end
end

Skeleton.SoftDelete.Repo.start_link()
Ecto.Adapters.SQL.Sandbox.mode(Skeleton.SoftDelete.Repo, :manual)

ExUnit.start()
