defmodule CaveaticaControllerWeb.PageController do
  use CaveaticaControllerWeb, :controller

  def health(conn, _params) do
    text(conn, "OK")
  end
end
