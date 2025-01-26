defmodule CaveaticaControllerWeb.HomeLive.Index do
  use CaveaticaControllerWeb, :live_view

  require Logger

  alias CaveaticaController.Scheduler
  alias Phoenix.PubSub

  @impl true
  def render(assigns) do
    ~H"""
    <h1 class="mb-4 text-4xl">Caveatica Live</h1>

    <div class="flex flex-row">
      <div>
        <div class="flex flex-col">
          <img src={@image_path} title={@image_age} />
          <div class="text-sm"><%= @image_age %></div>
        </div>

        <div class="mt-4">
          <div class="flex flex-col">
            <.simple_form for={@light_form} id="light_form" phx-change="change-light">
              <div>Light</div>
              <div class="flex flex-row gap-6">
                <.input type="radio" field={@light_form[:state]} value="off" label="Off" />
                <.input type="radio" field={@light_form[:state]} value="on" label="On" />
              </div>
            </.simple_form>
          </div>
          <div class="text-sm">Jobs: <pre><%= inspect(@jobs) %></pre></div>
        </div>
      </div>

      <div class="ml-4 flex flex-row">
        <div class="flex flex-col">
          <div>
            <button class="w-64 p-2 rounded bg-gray-300 color-white text-3xl" phx-click="nudge-open">
              <div class="flex flex-col">
                <div>^</div>
                <div>Step open</div>
              </div>
            </button>
          </div>

          <div class="mt-4">
            <button class="w-64 p-2 rounded bg-gray-300 color-white text-3xl" phx-click="open">
              <div class="flex flex-col">
                <div>^^</div>
                <div>Open</div>
              </div>
            </button>
          </div>

          <div class="mt-4">
            <button class="w-64 p-2 rounded bg-gray-300 color-white text-3xl" phx-click="close">
              <div class="flex flex-col">
                <div>Close</div>
                <div class="transform rotate-180">^^</div>
              </div>
            </button>
          </div>

          <div class="mt-4">
            <button class="w-64 p-2 rounded bg-gray-300 color-white text-3xl" phx-click="nudge-closed">
              <div class="flex flex-col">
                <div>Step close</div>
                <div class="transform rotate-180">^</div>
              </div>
            </button>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    PubSub.subscribe(CaveaticaController.PubSub, "image_upload")

    jobs = Scheduler.jobs()

    socket
    |> assign(:image_path, nil)
    |> assign(:image_age, nil)
    |> assign(:jobs, jobs)
    |> set_light("off")
    |> ok()
  end

  @impl true
  def handle_event("close", _params, socket) do
    CaveaticaControllerWeb.Endpoint.broadcast!("control", "close", %{})
    noreply(socket)
  end

  def handle_event("nudge-closed", _params, socket) do
    Logger.info("HomeLive.Index handle_event nudge-closed")
    CaveaticaControllerWeb.Endpoint.broadcast!("control", "nudge_closed", %{})
    noreply(socket)
  end

  def handle_event("nudge-open", _params, socket) do
    Logger.info("HomeLive.Index handle_event nudge-open")
    CaveaticaControllerWeb.Endpoint.broadcast!("control", "nudge_open", %{})
    noreply(socket)
  end

  def handle_event("open", _params, socket) do
    CaveaticaControllerWeb.Endpoint.broadcast!("control", "open", %{})
    noreply(socket)
  end

  def handle_event("change-light", %{"light" => %{"state" => state}}, socket) do
    Logger.info("HomeLive.Index handle_event change-light: #{inspect(state)}")
    CaveaticaControllerWeb.Endpoint.broadcast!("control", "light", %{"state" => state})

    socket
    |> set_light(state)
    |> noreply()
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

  defp set_light(socket, state) do
    socket
    |> assign(:light_form, to_form(%{"state" => state}, as: "light"))
  end
end
