# Sobre o Skeleton SoftDelete

O Skeleton SoftDelete ajuda no tratamento de dados excluídos em sua aplicação, onde, nada é realmente deletado.
O que o SoftDelete faz é sempre que houver um delete em uma tabela, ele irá marcar com uma flag `deleted_at` a linha demostrando
que foi excluída.
Toda técnica se baseia na criação de views, triggers e funções diretamente no banco de dados.

# Funcionamento

## Função para exclusão

A funcão `soft_delete()` é responsável por marcar a linha como excluída, ou seja, receberá um valor na coluna `deleted_at`.

## View filtrando registro ativos

A view receberá o nome da sua tabela + `_without_deleted`.
Ela será sua tabela de registros ativos, filtrando os registro deletados.
É essa view que você precisará utilizar no seu schema (elixir).

## Trigger que invocará a função de exclusão

Essa view será criada em sua view, onde, após um `DELETE`, será invocada a funcão `soft_delte` e ao invés de
excluir, será marcada como excluída.

## View VS tabela

É importante entender a diferença entre a view e sua tabela.
A view é nada mais é do que uma query em sua tabela, filtrnado por registro não removidos. Já
a tabela, funciona de maneira normal, retornando todos os dados, incluíndo os excluídos.

## Instalação

```elixir
def deps do
  [
    {:skeleton_soft_delete, github: "skeleton-elixir/skeleton_soft_delete"},
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
defmodule App do
  def schema do
    quote do
      use Ecto.Schema
      use Skeleton.SoftDelete.Schema
      import Ecto.Changeset

      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id
      @timestamps_opts [type: :naive_datetime_usec]
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
defmodule App.Repo.Migrations.CreateUsers do
  use App, :migration

  def change do
    before_setup_soft_delete(:users, :user)

    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :string

      timestamps()
    end

    create unique_index(:users, [:email])

    after_setup_soft_delete(:users, :user)
  end
end
```

A função `before_setup_soft_delete` será responsável, por recriar a função `soft_delete`,
remover a view `_without_deleted` da sua tabela e por fim remover a trigger criada na view.
Isso se faz necessário, pois caso você venha alterar ou adicionar uma columna em sua tabela, você tenha
a view atualizada junto a trigger.

Já a funcão `after_setup_soft_delete` irã criar a columna `deleted_at` em sua tabela, junto com o índice, view e trigger.

### Criando o Schema

```elixir
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
Você poderá realizar queries com segurança nesse schema `User`, pois ele sempre filtrará os
registros excluídos.

Caso voê precise realmente trazer os registros excluídos em uma query, basta utilizar o Schema assim: `User.with_deleted()`.