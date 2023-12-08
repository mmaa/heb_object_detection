defmodule ObjectDetectionWeb.ImageControllerTest do
  use ObjectDetectionWeb.ConnCase

  @create_attrs %{
    label: "some label",
    object_detection_enabled: false,
    mime_type: "image/jpeg",
    image_base64: "c29tZSBiaW5hcnk="
  }
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all images", %{conn: conn} do
      post(conn, ~p"/images", @create_attrs)

      conn = get(conn, ~p"/images")

      assert [
               %{
                 "id" => _id,
                 "label" => "some label",
                 "object_detection_enabled" => false,
                 "image_url" => nil,
                 "mime_type" => "image/jpeg",
                 "objects" => nil
               }
             ] = json_response(conn, 200)["data"]
    end
  end

  describe "create image" do
    test "renders image when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/images", @create_attrs)

      assert %{
               "id" => id,
               "label" => "some label",
               "object_detection_enabled" => false,
               "image_url" => nil,
               "mime_type" => "image/jpeg",
               "objects" => nil
             } = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/images/#{id}")

      assert %{
               "id" => ^id,
               "label" => "some label",
               "object_detection_enabled" => false,
               "image_url" => nil,
               "mime_type" => "image/jpeg",
               "objects" => nil
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/images", image: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end
end
