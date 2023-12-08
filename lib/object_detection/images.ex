defmodule ObjectDetection.Images do
  @moduledoc """
  The Images context.
  """

  import Ecto.Query, warn: false
  alias ObjectDetection.Repo

  alias ObjectDetection.Images.Image

  @doc """
  Returns the list of images.

  ## Examples

      iex> list_images()
      [%Image{}, ...]

  """
  def list_images(objects \\ []) do
    if Enum.any?(objects) do
      Image
      |> where(fragment("? && objects", ^objects))
      |> Repo.all()
    else
      Repo.all(Image)
    end
  end

  @doc """
  Gets a single image.

  Raises `Ecto.NoResultsError` if the Image does not exist.

  ## Examples

      iex> get_image!(123)
      %Image{}

      iex> get_image!(456)
      ** (Ecto.NoResultsError)

  """
  def get_image!(id), do: Repo.get!(Image, id)

  @doc """
  Creates a image.

  ## Examples

      iex> create_image(%{field: value})
      {:ok, %Image{}}

      iex> create_image(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_image(attrs \\ %{}) do
    case %Image{}
         |> Image.create_changeset(attrs)
         |> Repo.insert() do
      {:ok, image} ->
        if image.object_detection_enabled do
          case detect_objects!(image) do
            {:ok, objects} ->
              {:ok, update_image(image, %{objects: objects})}

            _ ->
              {:ok, image}
          end
        else
          {:ok, image}
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Updates a image.

  ## Examples

      iex> update_image(image, %{field: new_value})
      {:ok, %Image{}}

      iex> update_image(image, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_image(%Image{} = image, attrs) do
    image
    |> Image.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a image.

  ## Examples

      iex> delete_image(image)
      {:ok, %Image{}}

      iex> delete_image(image)
      {:error, %Ecto.Changeset{}}

  """
  def delete_image(%Image{} = image) do
    Repo.delete(image)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking image changes.

  ## Examples

      iex> change_image(image)
      %Ecto.Changeset{data: %Image{}}

  """
  def change_image(%Image{} = image, attrs \\ %{}) do
    Image.update_changeset(image, attrs)
  end

  @doc """
  Makes and external API call to detect objects in an image.
  """
  def detect_objects!(%Image{} = image, threshold \\ 25) do
    case Req.post(req(), form: [image_base64: Base.encode64(image.binary), threshold: threshold]) do
      {:ok,
       %Req.Response{
         status: 200,
         body: %{
           "status" => %{"type" => "success"},
           "result" => %{"tags" => tags}
         }
       }} ->
        {:ok,
         tags
         |> Enum.map(fn %{"tag" => %{"en" => object}} -> object end)}
    end
  end

  def req() do
    api_key = Application.get_env(:object_detection, :imagga_credentials)[:api_key]
    api_secret = Application.get_env(:object_detection, :imagga_credentials)[:api_secret]

    Req.new(
      url: "https://api.imagga.com/v2/tags",
      auth: {:basic, "#{api_key}:#{api_secret}"}
    )
  end
end
