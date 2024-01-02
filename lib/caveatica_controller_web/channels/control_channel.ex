defmodule CaveaticaControllerWeb.ControlChannel do
  use Phoenix.Channel

  require Logger

  def join("control", _message, socket) do
    Logger.info("Control channel joined")
    {:ok, %{ok: "good"}, socket}
  end

  def handle_in("get_metrics", _params, socket) do
    Logger.info("Control channel get_metrics")
    {:reply, {:ok, %{result: "ok"}}, socket}
    #{:noreply, socket}
  end
end
