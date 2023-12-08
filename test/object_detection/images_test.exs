defmodule ObjectDetection.ImagesTest do
  use ObjectDetection.DataCase

  alias ObjectDetection.Images

  describe "images" do
    alias ObjectDetection.Images.Image

    import ObjectDetection.ImagesFixtures

    @invalid_attrs %{label: nil, object_detection_enabled: nil, url: nil, binary: nil}

    test "list_images/1 with no object filter returns all images" do
      image = image_fixture()
      assert Images.list_images() == [image]
    end

    test "list_images/1 with list of objects returns images containing any of the objects" do
      dog_image = image_fixture(%{label: "dog", objects: ["dog", "cow"]})
      cat_image = image_fixture(%{label: "cat", objects: ["cat", "cow"]})
      _cow_image = image_fixture(%{label: "cow", objects: ["cow"]})

      assert Images.list_images(["dog", "cat"]) == [dog_image, cat_image]
    end

    test "get_image!/1 returns the image with given id" do
      image = image_fixture()
      assert Images.get_image!(image.id) == image
    end

    test "create_image/1 with valid data creates a image" do
      valid_attrs = %{
        label: "some label",
        object_detection_enabled: false,
        type: "image/jpeg",
        binary: "some binary"
      }

      assert {:ok, %Image{} = image} = Images.create_image(valid_attrs)
      assert image.label == "some label"
      assert image.object_detection_enabled == false
      assert image.binary == "some binary"
    end

    test "create_image/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Images.create_image(@invalid_attrs)
    end

    test "update_image/2 with valid data updates the image" do
      image = image_fixture()

      update_attrs = %{
        objects: ["foo", "bar"]
      }

      assert {:ok, %Image{} = image} = Images.update_image(image, update_attrs)
      assert image.objects == ["foo", "bar"]
    end

    test "delete_image/1 deletes the image" do
      image = image_fixture()
      assert {:ok, %Image{}} = Images.delete_image(image)
      assert_raise Ecto.NoResultsError, fn -> Images.get_image!(image.id) end
    end

    test "change_image/1 returns a image changeset" do
      image = image_fixture()
      assert %Ecto.Changeset{} = Images.change_image(image)
    end
  end
end
