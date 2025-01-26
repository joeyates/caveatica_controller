defmodule CaveaticaControllerWeb.ControlChannel do
  use Phoenix.Channel

  require Logger

  alias Phoenix.PubSub

  def join("control", _message, socket) do
    Logger.info("Control channel joined")
    {:ok, %{ok: "good"}, socket}
  end

  def handle_in("get_metrics", _params, socket) do
    Logger.debug("Control channel get_metrics")
    {:reply, {:ok, %{result: "ok"}}, socket}
  end

  def handle_in("upload_image", %{"binary" => encoded}, socket) do
    binary = Base.decode64!(encoded)
    Logger.debug("Control channel upload_image, binary: #{byte_size(binary)}")
    {:ok, path, age} = CaveaticaController.Images.receive(binary)
    PubSub.broadcast(CaveaticaController.PubSub, "image_upload", {:image_upload, path, age})
    {:noreply, socket}
  end
end
