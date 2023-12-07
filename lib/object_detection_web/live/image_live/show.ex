defmodule ObjectDetectionWeb.ImageLive.Show do
  use ObjectDetectionWeb, :live_view

  alias ObjectDetection.Images

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:image, Images.get_image!(id))}
  end

  defp page_title(:show), do: "Show Image"
end
