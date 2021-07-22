# Sobre o Skeleton SoftDelete

O Skeleton SoftDelete ajuda no tratamento de dados excluídos em sua aplicação, onde, nada é realmente deletado.
O que o SoftDelete faz é sempre que houver um delete em uma tabela, ele irá marcar com uma flag `deleted_at` a linha para desmonstrar que foi excluída.
Toda técnica se baseia na criação de views, triggers e funções diretamente no banco de dados.

# Funcionamento

## Função para exclusão

A funcão `soft_delete()` é responsável por marcar a linha como excluída, ou seja, receberá um valor na coluna `deleted_at`.

## View filtrando registro ativos

A view receberá o nome da sua tabela + `_without_deleted`.
Ela será sua tabela de registros ativos, filtrando os registro deletados.
É essa view que você precisará utilizar no seu schema (elixir).

## Trigger que invocará a função de exclusão

Essa função será criada em sua view, onde, após um `DELETE` no banco, será invocada a funcão `soft_delte` e ao invés de excluir, será marcada como excluída.

## View VS tabela

É importante entender a diferença entre a view e sua tabela.
A view é nada mais é do que uma query em sua tabela, filtrnado por registro não removidos. Já
a tabela, funciona de maneira normal, retornando todos os dados, incluíndo os excluídos.

## Instalação

```elixir
def deps do
  [
    {:skeleton_soft_delete, "~> 1.0.0"}
  ]
end
```

## Configuração

```elixir
config :skeleton_soft_delete, view_suffix: "_without_deleted"
```

Essa é a configuração padrão, você não precisa declará-la se não desejar mudar o sufixo da view.

## Criando o contexto

```elixir
# lib/app/app.ex

defmodule App do
  def schema do
    quote do
      use Ecto.Schema
      import Skeleton.SoftDelete.Schema
      import Ecto.Changeset
    end
  end

  def migration do
    quote do
      use Ecto.Migration
      import Skeleton.SoftDelete.Migration
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
```

### Criando a migration

```elixir
# priv/migrations/00000000000000_create_users.exs

defmodule App.Repo.Migrations.CreateUsers do
  use App, :migration

  def change do
    before_setup_soft_delete(:users, :user)

    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :string

      add_soft_delete_field()

      timestamps()
    end

    create unique_index(:users, [:email])

    after_setup_soft_delete(:users, :user)
  end
end
```

A função `before_setup_soft_delete` será responsável por remover a view `_without_deleted` caso a mesma tenha sido criada anteriormente e tamém a trigger responsável por não deletar o registro e sim informar uma data de deleção `deleted_at`. Essa remoção se faz necessária pois caso seja incluído ou alterado um algum campo, as atualizações dos campos serão contemplados na nova view que será criada através da função `after_setup_soft_delete` que será detalhada a baixo.

A funcão `add_soft_delete_field()` irá criar a columna `deleted_at` em sua tabela. Essa coluna será responsável por informar que e quando aquele registro foi excluído.
A função `after_setup_soft_delete` será responsável por recriar a view `_without_deleted` e também a trigger do soft_delete.

### Criando o Schema

```elixir
# lib/app/accounts/user/user.ex

defmodule App.Accounts.User do
  use App, :schema

  schema soft_delete("users") do
    field :email, :string

    soft_delete_field()
    timestamps()
  end

  def with_deleted do
    {"users", App.Accounts.User}
  end
end
```

A partir de agora, qualquer `Repo.delete` utilizando seu schema `User`, irá sinalizar que a linha foi excluída.
Você poderá realizar queries com segurança nesse schema `User`, pois ele sempre filtrará os registros excluídos.

Caso você precise realmente trazer os registros excluídos em uma query, basta utilizar o Schema assim: `User.with_deleted()`, exemplo: `Repo.all(User.with_deleted())` trará todos os registros, incluindo os deletados. Já Repo.all(User) trará apenas os registros que não foram marcados como deletados, ou seja, os que o processo do soft_delete não incluiu uma data no campo `deleted_at`.
