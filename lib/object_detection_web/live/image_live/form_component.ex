defmodule ObjectDetectionWeb.ImageLive.FormComponent do
  use ObjectDetectionWeb, :live_component

  alias ObjectDetection.Images

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.simple_form for={@form} id="image-form" phx-target={@myself} phx-change="validate" phx-submit="save">
        <.input field={@form[:label]} type="text" label="Label" />
        <.input field={@form[:url]} type="text" label="URL or Uploaded Image" />
        <.live_file_input upload={@uploads.image} />
        <.input field={@form[:object_detection_enabled]} type="checkbox" label="Detect objects" checked />

        <:actions>
          <.button phx-disable-with="Saving...">Save Image</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> allow_upload(:image, accept: ~w(.jpg .jpeg .png .gif), max_file_size: 512_000)}
  end

  @impl true
  def update(%{image: image} = assigns, socket) do
    changeset = Images.change_image(image)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"image" => image_params}, socket) do
    changeset =
      socket.assigns.image
      |> Images.change_image(image_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"image" => image_params}, socket) do
    image_params =
      case consume_uploaded_entries(socket, :image, fn %{path: path}, entry ->
             image_params =
               image_params
               |> Map.put("type", entry.client_type)
               |> Map.put("binary", File.read!(path))

             {:ok, image_params}
           end) do
        [new_params] ->
          new_params

        [] ->
          image_params
      end

    save_image(socket, socket.assigns.action, image_params)
  end

  defp save_image(socket, :edit, image_params) do
    case Images.update_image(socket.assigns.image, image_params) do
      {:ok, image} ->
        notify_parent({:saved, image})

        {:noreply,
         socket
         |> put_flash(:info, "Image updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_image(socket, :new, image_params) do
    case Images.create_image(image_params) do
      {:ok, image} ->
        notify_parent({:saved, image})

        {:noreply,
         socket
         |> put_flash(:info, "Image created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
