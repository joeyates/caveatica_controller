defmodule CaveaticaControllerWeb.ControlChannel do
  use Phoenix.Channel

  require Logger

  alias Phoenix.PubSub

  def join("control", _message, socket) do
    Logger.info("Control channel joined")
    {:ok, %{ok: "good"}, socket}
  end

  def handle_in("get_metrics", _params, socket) do
    Logger.info("Control channel get_metrics")
    {:reply, {:ok, %{result: "ok"}}, socket}
  end

  def handle_in("upload_image", %{"binary" => encoded}, socket) do
    binary = Base.decode64!(encoded)
    Logger.info("Control channel upload_image, binary: #{byte_size(binary)}")
    File.write!(original_path(), binary)
    PubSub.broadcast(CaveaticaController.PubSub, "image_upload", {:image_upload})
    {:noreply, socket}
  end

  defp data_path do
    Application.fetch_env!(:caveatica_controller, :data_path)
  end

  defp original_path do
    Path.join(data_path(), "caveatica.jpg")
  end
end
