defmodule CaveaticaControllerWeb.HomeLive.Index do
  use CaveaticaControllerWeb, :live_view

  require Logger

  alias CaveaticaController.Cldr.DateTime.Relative
  alias Phoenix.PubSub

  @server_timezone "Etc/UTC"
  @user_timezone "Europe/Rome"
  @maximum_image_dimension 320

  @impl true
  def mount(_params, _session, socket) do
    PubSub.subscribe(CaveaticaController.PubSub, "image_upload")
    {
      :ok,
      socket
      |> assign(:image_path, nil)
      |> assign(:image_timestamp, nil)
      |> assign_image_age()
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
  def handle_info({:image_upload}, socket) do
    Logger.info("HomeLive.Index handle_info image_upload")
    {:noreply, process_image(socket)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, assign(socket, :page_title, "Caveatica")}
  end

  defp process_image(socket) do
    original_path = original_path()
    original_exists = File.exists?(original_path)

    if original_exists do
      Logger.info("HomeLive.Index process_image/1")
      timestamp = timestamp(original_path)
      converted_path = converted_path()
      :ok = rotate_90(original_path, converted_path)
      epoch = DateTime.to_unix(timestamp)
      socket
      |> assign(:image_path, "/data/converted.jpg?time=#{epoch}")
      |> assign(:image_timestamp, timestamp)
      |> assign_image_age()
    else
      socket
    end
  end

  defp data_path do
    Application.fetch_env!(:caveatica_controller, :data_path)
  end

  defp original_path do
    Path.join(data_path(), "caveatica.jpg")
  end

  defp converted_path do
    Path.join(data_path(), "converted.jpg")
  end

  defp assign_image_age(socket) do
    timestamp = socket.assigns.image_timestamp
    image_age = if timestamp do
      ago = Relative.to_string!(timestamp)
      "Image created #{ago} (#{timestamp})"
    else
      "No image"
    end
    assign(socket, :image_age, image_age)
  end

  defp timestamp(path) do
    stat = File.stat!(path)
    {erl_date, erl_time} = stat.mtime
    time = Time.from_erl!(erl_time)
    date = Date.from_erl!(erl_date)
    DateTime.new!(date, time, @server_timezone)
    |> DateTime.shift_zone!(@user_timezone)
  end

  def rotate_90(from, to) do
    System.cmd(
      "convert",
      [
        from,
        "-rotate", "90",
        "-gravity", "center",
        "-crop", "#{@maximum_image_dimension}x#{@maximum_image_dimension}",
        to
      ]
    )
    :ok
  end
end
