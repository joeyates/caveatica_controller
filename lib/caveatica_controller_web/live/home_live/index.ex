defmodule CaveaticaControllerWeb.HomeLive.Index do
  use CaveaticaControllerWeb, :live_view

  @image_path Application.compile_env(:caveatica_controller, :webcam_image_path)

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :image_path, @image_path)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, assign(socket, :page_title, "Caveatica")}
  end
end
