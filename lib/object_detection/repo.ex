defmodule ObjectDetection.Repo do
  use Ecto.Repo,
    otp_app: :object_detection,
    adapter: Ecto.Adapters.Postgres
end
