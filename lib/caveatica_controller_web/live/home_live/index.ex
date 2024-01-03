defmodule CaveaticaControllerWeb.HomeLive.Index do
  use CaveaticaControllerWeb, :live_view

  require Logger

  alias Phoenix.PubSub

  @impl true
  def render(assigns) do
    ~H"""
    <h1 class="mb-4 text-4xl">Caveatica Live</h1>

    <img src={@image_path}>
    <div><%= @image_age %></div>

    <div>
      <button class="text-3xl" phx-click="nudge-open">Step open ^</button>
    </div>

    <div>
      <button class="text-3xl" phx-click="open">Open fully ^^</button>
    </div>

    <div>
      <button class="text-3xl" phx-click="close">Close fully vv</button>
    </div>

    <div>
      <button class="text-3xl" phx-click="nudge-closed">Step close v</button>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    PubSub.subscribe(CaveaticaController.PubSub, "image_upload")
    {
      :ok,
      socket
      |> assign(:image_path, nil)
      |> assign(:image_age, nil)
    }
  end

  @impl true
  def handle_event("close", _params, socket) do
    CaveaticaControllerWeb.Endpoint.broadcast!("control", "close", %{})
    {:noreply, socket}
  end

  def handle_event("nudge-closed", _params, socket) do
    CaveaticaControllerWeb.Endpoint.broadcast!("control", "nudge_closed", %{})
    {:noreply, socket}
  end

  def handle_event("nudge-open", _params, socket) do
    CaveaticaControllerWeb.Endpoint.broadcast!("control", "nudge_open", %{})
    {:noreply, socket}
  end

  def handle_event("open", _params, socket) do
    CaveaticaControllerWeb.Endpoint.broadcast!("control", "open", %{})
    {:noreply, socket}
  end

  @impl true
  def handle_info({:image_upload, path, age}, socket) do
    Logger.info("HomeLive.Index handle_info image_upload")
    {
      :noreply,
      socket
      |> assign(image_path: path)
      |> assign(image_age: age)
    }
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, assign(socket, :page_title, "Caveatica")}
  end
end
