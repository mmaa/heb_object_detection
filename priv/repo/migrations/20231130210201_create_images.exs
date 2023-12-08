defmodule ObjectDetection.Repo.Migrations.CreateImages do
  use Ecto.Migration

  def change do
    create table(:images) do
      add :label, :string, null: false
      add :object_detection_enabled, :boolean, null: false
      add :url, :string
      add :type, :string
      add :binary, :binary
      add :objects, {:array, :string}

      timestamps(type: :utc_datetime)
    end

    create unique_index(:images, [:label])
    create index(:images, [:objects], using: :gin)
  end
end
