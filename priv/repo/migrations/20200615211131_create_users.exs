defmodule Skeleton.App.Repo.Migrations.CreateUsers do
  use Skeleton.App, :migration

  def change do
    before_setup_soft_delete(:users, :user)

    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :email, :string

      soft_delete()
      timestamps()
    end

    create unique_index(:users, [:email])

    after_setup_soft_delete(:users, :user)
  end
end
