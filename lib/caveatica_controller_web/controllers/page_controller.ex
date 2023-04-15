defmodule CaveaticaControllerWeb.PageController do
  use CaveaticaControllerWeb, :controller

  @image_path Application.compile_env(:caveatica_controller, :webcam_image_path)

  def home(conn, _params) do
    conn
    |> assign(:image_path, @image_path)
    |> render(:home, layout: false)
  end
end
