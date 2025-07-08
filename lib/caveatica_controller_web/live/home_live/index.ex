defmodule CaveaticaControllerWeb.HomeLive.Index do
  use CaveaticaControllerWeb, :live_view

  require Logger

  alias CaveaticaController.LiveSettings
  alias CaveaticaController.Scheduler
  alias Phoenix.PubSub

  @impl true
  def mount(_params, _session, socket) do
    PubSub.subscribe(CaveaticaController.PubSub, "image_upload")

    close_duration = LiveSettings.get_close_duration()
    open_duration = LiveSettings.get_open_duration()

    socket
    |> assign(:image_path, nil)
    |> assign(:image_age, nil)
    |> assign(:close_duration, close_duration)
    |> assign(:open_duration, open_duration)
    |> assign_open_close()
    |> set_light("off")
    |> ok()
  end

  @impl true
  def render(assigns) do
    ~H"""
    <h1 class="mb-4 text-4xl">Caveatica Live</h1>

    <div class="flex flex-row">
      <div class="flex-1 flex flex-col gap-4">
        <img src={@image_path} title={@image_age} />
        <div class="text-sm"><%= @image_age %></div>

        <div class="flex flex-col gap-4">
          <.simple_form for={@light_form} id="light_form" phx-change="change-light">
            <div>Light</div>
            <div class="flex flex-row gap-6">
              <.input type="radio" field={@light_form[:state]} value="off" label="Off" />
              <.input type="radio" field={@light_form[:state]} value="on" label="On" />
            </div>
          </.simple_form>
        </div>

        <div class="text-2xl">Open</div>
        <button
          class="p-2 rounded bg-gray-300 color-white text-3xl"
          phx-click="increase-open-duration"
        >
          +
        </button>
        <div class="text-2xl text-center"><%= @open_duration %> ms</div>
        <button
          class="p-2 rounded bg-gray-300 color-white text-3xl"
          phx-click="decrease-open-duration"
        >
          -
        </button>

        <div class="text-sm">Next open: <%= @next_open %></div>

        <div class="text-2xl">Close</div>
        <button
          class="p-2 rounded bg-gray-300 color-white text-3xl"
          phx-click="increase-close-duration"
        >
          +
        </button>
        <div class="text-2xl text-center"><%= @close_duration %> ms</div>
        <button
          class="p-2 rounded bg-gray-300 color-white text-3xl"
          phx-click="decrease-close-duration"
        >
          -
        </button>

        <div class="text-sm">Next close: <%= @next_close %></div>
      </div>

      <div class="ml-4 flex flex-row">
        <div class="flex flex-col items-center">
          <button class="p-2 rounded bg-gray-300 color-white text-3xl" phx-click="nudge-open">
            <div class="flex flex-col">
              <div>^</div>
              <div>Step open</div>
            </div>
          </button>

          <button class="mt-4 p-2 rounded bg-gray-300 color-white text-3xl" phx-click="open">
            <div class="flex flex-col">
              <div>^^</div>
              <div>Open</div>
            </div>
          </button>

          <button class="mt-4 p-2 rounded bg-gray-300 color-white text-3xl" phx-click="close">
            <div class="flex flex-col">
              <div>Close</div>
              <div class="transform rotate-180">^^</div>
            </div>
          </button>

          <button class="mt-4 p-2 rounded bg-gray-300 color-white text-3xl" phx-click="nudge-closed">
            <div class="flex flex-col">
              <div>Step close</div>
              <div class="transform rotate-180">^</div>
            </div>
          </button>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("close", _params, socket) do
    duration = socket.assigns.close_duration
    Logger.info("HomeLive.Index handle_event close (#{duration} ms)")
    CaveaticaControllerWeb.Endpoint.broadcast!("control", "close", %{"duration" => duration})

    noreply(socket)
  end

  def handle_event("nudge-closed", _params, socket) do
    Logger.info("HomeLive.Index handle_event nudge-closed")
    CaveaticaControllerWeb.Endpoint.broadcast!("control", "close", %{"duration" => 100})
    noreply(socket)
  end

  def handle_event("nudge-open", _params, socket) do
    Logger.info("HomeLive.Index handle_event nudge-open")
    CaveaticaControllerWeb.Endpoint.broadcast!("control", "open", %{"duration" => 100})
    noreply(socket)
  end

  def handle_event("open", _params, socket) do
    duration = socket.assigns.open_duration
    Logger.info("HomeLive.Index handle_event open (#{duration} ms)")

    CaveaticaControllerWeb.Endpoint.broadcast!("control", "open", %{"duration" => duration})

    noreply(socket)
  end

  def handle_event("change-light", %{"light" => %{"state" => state}}, socket) do
    Logger.info("HomeLive.Index handle_event change-light: #{inspect(state)}")
    CaveaticaControllerWeb.Endpoint.broadcast!("control", "light", %{"state" => state})

    socket
    |> set_light(state)
    |> noreply()
  end

  def handle_event("decrease-open-duration", _params, socket) do
    Logger.info("HomeLive.Index handle_event decrease-open-duration")

    socket
    |> optionally_update_open_duration(-100)
    |> noreply()
  end

  def handle_event("increase-open-duration", _params, socket) do
    Logger.info("HomeLive.Index handle_event increase-open-duration")

    socket
    |> optionally_update_open_duration(100)
    |> noreply()
  end

  def handle_event("decrease-close-duration", _params, socket) do
    Logger.info("HomeLive.Index handle_event decrease-close-duration")

    socket
    |> optionally_update_close_duration(-100)
    |> noreply()
  end

  def handle_event("increase-close-duration", _params, socket) do
    Logger.info("HomeLive.Index handle_event increase-close-duration")

    socket
    |> optionally_update_close_duration(100)
    |> noreply()
  end

  defp optionally_update_open_duration(socket, delta) do
    existing = socket.assigns.open_duration
    updated = existing + delta

    if updated > 100 && updated <= 20000 do
      LiveSettings.set_open_duration(updated)
      assign(socket, :open_duration, updated)
    else
      socket
    end
  end

  defp optionally_update_close_duration(socket, delta) do
    existing = socket.assigns.close_duration
    updated = existing + delta

    if updated > 100 && updated <= 20000 do
      LiveSettings.set_close_duration(updated)
      assign(socket, :close_duration, updated)
    else
      socket
    end
  end

  @impl true
  def handle_info({:image_upload, path, age}, socket) do
    Logger.debug("HomeLive.Index handle_info image_upload")

    socket
    |> assign(image_path: path)
    |> assign(image_age: age)
    |> noreply()
  end

  @impl true
  def handle_params(_params, _url, socket) do
    socket
    |> assign(:page_title, "Caveatica")
    |> noreply()
  end

  defp assign_open_close(socket) do
    next_open = Scheduler.next_open()
    next_close = Scheduler.next_close()

    socket
    |> assign(:next_open, next_open)
    |> assign(:next_close, next_close)
  end

  defp set_light(socket, state) do
    socket
    |> assign(:light_form, to_form(%{"state" => state}, as: "light"))
  end
end
