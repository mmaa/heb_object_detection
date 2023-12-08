defmodule ObjectDetectionWeb.ImageLiveTest do
  use ObjectDetectionWeb.ConnCase

  import Phoenix.LiveViewTest
  import ObjectDetection.ImagesFixtures

  @create_attrs %{
    object_detection_enabled: false,
    url: "http://s3.mmaa.co/frysquint.jpg"
  }

  defp create_image(_) do
    image = image_fixture()
    %{image: image}
  end

  describe "Index" do
    setup [:create_image]

    test "lists all images", %{conn: conn, image: image} do
      {:ok, _index_live, html} = live(conn, ~p"/")

      assert html =~ "Listing Images"
      assert html =~ image.label
    end

    test "saves new image", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/")

      assert index_live |> element("a", "New Image") |> render_click() =~
               "New Image"

      assert_patch(index_live, ~p"/new")

      assert index_live
             |> form("#image-form", image: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/")

      html = render(index_live)
      assert html =~ "Image created successfully"
      assert html =~ "some label"
    end

    test "deletes image in listing", %{conn: conn, image: image} do
      {:ok, index_live, _html} = live(conn, ~p"/")

      assert index_live |> element("#images-#{image.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#images-#{image.id}")
    end
  end

  describe "Show" do
    setup [:create_image]

    test "displays image", %{conn: conn, image: image} do
      {:ok, _show_live, html} = live(conn, ~p"/#{image}")

      assert html =~ "Show Image"
      assert html =~ image.label
    end
  end
end
