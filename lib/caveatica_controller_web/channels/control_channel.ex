defmodule CaveaticaControllerWeb.ControlChannel do
  use Phoenix.Channel

  require Logger

  alias Phoenix.PubSub

  def join("control", _message, socket) do
    Logger.info("Control channel joined")
    {:ok, %{ok: "good"}, socket}
  end

  @doc """
  Caveatica sends the following types of requests:

  * a status update every 3 seconds,
  * an image upload every second.
  """
  def handle_in("status", status, socket) do
    Logger.info("Control channel status: #{inspect(status)}")
    PubSub.broadcast(CaveaticaController.PubSub, "caveatica_status", {:status_update, status})
    {:noreply, socket}
  end

  def handle_in("upload_image", %{"binary" => encoded}, socket) do
    binary = Base.decode64!(encoded)
    Logger.debug("Control channel upload_image, binary: #{byte_size(binary)}")
    {:ok, path, age} = CaveaticaController.Images.receive(binary)
    PubSub.broadcast(CaveaticaController.PubSub, "image_upload", {:image_upload, path, age})
    {:noreply, socket}
  end
end
