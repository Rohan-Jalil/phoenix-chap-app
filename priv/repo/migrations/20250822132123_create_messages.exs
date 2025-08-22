defmodule MyChat.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :username, :string
      add :body, :text
      add :room, :string

      timestamps(type: :utc_datetime)
    end
  end
end
