defmodule CaveaticaControllerWeb.ControlSocket do
  use Phoenix.Socket

  require Logger

  channel "control", CaveaticaControllerWeb.ControlChannel

  @impl true
  def connect(_params, socket, _connect_info) do
    Logger.info("Control socket connected")
    {:ok, socket}
  end

  @impl true
  def id(_socket), do: nil
end
