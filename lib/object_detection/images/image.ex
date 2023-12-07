defmodule ObjectDetection.Images.Image do
  use Ecto.Schema
  import Ecto.Changeset

  schema "images" do
    field :label, :string
    field :object_detection_enabled, :boolean
    field :url, :string
    field :type, :string
    field :binary, :binary
    field :binary_enhanced, :binary
    field :objects, {:array, :string}

    field :image_url, :string, virtual: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def create_changeset(image, attrs) do
    image
    |> cast(attrs, [:label, :url, :type, :binary, :object_detection_enabled, :binary_enhanced, :objects])
    |> ensure_label()
    |> validate_required([:label, :object_detection_enabled])
    |> validate_url_or_binary()
    |> validate_url()
    |> validate_required([:type, :binary])
    |> unique_constraint([:label])
  end

  def update_changeset(image, attrs) do
    image
    |> cast(attrs, [:binary_enhanced, :objects])
  end

  defp ensure_label(changeset) do
    if changeset.changes[:label] do
      changeset
    else
      label = for _ <- 1..8, into: "", do: <<Enum.random(~c"23456789abcdefghjkmnpqrstvwxyz")>>

      changeset
      |> put_change(:label, label)
    end
  end

  defp validate_url_or_binary(changeset) do
    changed_values = Map.keys(changeset.changes)

    if !Enum.member?(changed_values, :url) && !Enum.member?(changed_values, :binary) do
      changeset
      |> add_error(:url, "a URL or uploaded image is required")
    else
      changeset
    end
  end

  defp validate_url(changeset) do
    if is_nil(changeset.changes[:binary]) && changeset.changes[:url] do
      case fetch_image(changeset.changes[:url]) do
        {:ok, content_type, body} ->
          changeset
          |> put_change(:type, content_type |> List.first() |> String.split(";") |> List.first())
          |> put_change(:binary, body)

        {:error, message} ->
          changeset
          |> add_error(:url, message)
      end
    else
      changeset
    end
  end

  defp fetch_image(url) do
    try do
      case Req.get(url) do
        {:ok, %Req.Response{status: 200, body: body, headers: %{"content-type" => content_type}}} ->
          {:ok, content_type, body}

        {:ok, %Req.Response{status: 404}} ->
          {:error, "image not found"}

        {:error, %Mint.TransportError{reason: reason}} ->
          {:error, reason}
      end
    rescue
      ArgumentError ->
        {:error, "URL is not valid"}
    end
  end
end
