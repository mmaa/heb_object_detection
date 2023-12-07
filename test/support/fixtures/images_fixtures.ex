defmodule ObjectDetection.ImagesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ObjectDetection.Images` context.
  """

  @doc """
  Generate a image.
  """
  def image_fixture(attrs \\ %{}) do
    {:ok, image} =
      attrs
      |> Enum.into(%{
        label: "some label",
        object_detection_enabled: true,
        url: "http://s3.mmaa.co/frysquint.jpg"
      })
      |> ObjectDetection.Images.create_image()

    image
  end
end
