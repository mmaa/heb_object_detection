defmodule ObjectDetectionWeb.ImageJSON do
  alias ObjectDetection.Images.Image

  @doc """
  Renders a list of images.
  """
  def index(%{images: images}) do
    %{data: for(image <- images, do: data(image))}
  end

  @doc """
  Renders a single image.
  """
  def show(%{image: image}) do
    %{data: data(image)}
  end

  defp data(%Image{} = image) do
    %{
      id: image.id,
      label: image.label,
      object_detection_enabled: image.object_detection_enabled,
      image_url: image.url,
      mime_type: image.type,
      objects: image.objects
    }
  end
end
