defmodule ObjectDetectionWeb.ImageController do
  use ObjectDetectionWeb, :controller

  alias ObjectDetection.Images
  alias ObjectDetection.Images.Image

  action_fallback ObjectDetectionWeb.FallbackController

  def index(conn, params) do
    objects = params["objects"] |> to_string() |> String.split(",", trim: true)
    images = Images.list_images(objects)
    render(conn, :index, images: images)
  end

  def create(conn, image_params) do
    converted_params = %{
      "url" => image_params["image_url"],
      "type" => image_params["mime_type"],
      "binary" => if(image_params["image_base64"], do: Base.decode64!(image_params["image_base64"]))
    }

    image_params =
      image_params
      |> Map.merge(converted_params)

    with {:ok, %Image{} = image} <- Images.create_image(image_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/images/#{image}")
      |> render(:show, image: image)
    end
  end

  def show(conn, %{"id" => id}) do
    image = Images.get_image!(id)
    render(conn, :show, image: image)
  end
end
