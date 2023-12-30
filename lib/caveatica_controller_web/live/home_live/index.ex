defmodule CaveaticaControllerWeb.HomeLive.Index do
  use CaveaticaControllerWeb, :live_view

  alias CaveaticaController.Cldr.DateTime.Relative

  @caveatica_node :"caveatica@127.0.0.1"
  @this_node :"controller@127.0.0.1"
  @cookie :caveatica_cookie
  @ping_interval 1000 # ms
  @update_image_interval 500 # ms
  @update_image_age_interval 1000 # ms
  @server_timezone "Etc/UTC"
  @user_timezone "Europe/Rome"
  @maximum_image_dimension 320
  @close_time 4300 # ms
  @open_time 4900 # ms

  @impl true
  def mount(_params, _session, socket) do
    Node.start(@this_node)
    Node.set_cookie(@cookie)
    {
      :ok,
      socket
      |> check_availability()
      |> assign(:image_path, nil)
      |> assign(:image_timestamp, nil)
      |> process_image()
      |> update_image_age()
    }
  end

  @impl true
  def handle_event("close", _params, socket) do
    Node.spawn(@caveatica_node, Caveatica, :close, [@close_time])
    {:noreply, socket}
  end

  @impl true
  def handle_event("nudge-closed", _params, socket) do
    Node.spawn(@caveatica_node, Caveatica, :close, [30])
    {:noreply, socket}
  end

  @impl true
  def handle_event("nudge-open", _params, socket) do
    Node.spawn(@caveatica_node, Caveatica, :open, [30])
    {:noreply, socket}
  end

  @impl true
  def handle_event("open", _params, socket) do
    Node.spawn(@caveatica_node, Caveatica, :open, [@open_time])
    {:noreply, socket}
  end

  @impl true
  def handle_info(:check_availability, socket) do
    {:noreply, check_availability(socket)}
  end

  @impl true
  def handle_info(:update_image, socket) do
    {:noreply, process_image(socket)}
  end

  @impl true
  def handle_info(:update_image_age, socket) do
    {:noreply, update_image_age(socket)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, assign(socket, :page_title, "Caveatica")}
  end

  defp check_availability(socket) do
    Process.send_after(self(), :check_availability, @ping_interval)
    case Node.ping(@caveatica_node) do
      :pong ->
        assign(socket, :available, true)
      :pang ->
        assign(socket, :available, false)
    end
  end

  defp process_image(socket) do
    Process.send_after(self(), :update_image, @update_image_interval)

    original_relative_path = "./priv/static/#{static_image_path()}"
    original_exists = File.exists?(original_relative_path)
    have_image = if socket.assigns.image_path, do: true, else: false
    load_initial = !have_image && original_exists

    relative_lock_path = "./priv/static/#{lock_path()}"
    lock_exists = File.exists?(relative_lock_path)

    if load_initial || lock_exists do
      timestamp = timestamp(original_relative_path)
      converted_relative_path = "./priv/static/#{converted_path()}"
      :ok = rotate_90(original_relative_path, converted_relative_path)
      if lock_exists do
        File.rm(relative_lock_path)
      end
      epoch = DateTime.to_unix(timestamp)
      socket
      |> assign(:image_path, "/#{converted_path()}?time=#{epoch}")
      |> assign(:image_timestamp, timestamp)
      |> assign_image_age()
    else
      socket
    end
  end

  defp static_image_path do
    Application.fetch_env!(:caveatica_controller, :webcam_image_path)
  end

  defp lock_path, do: String.replace(static_image_path(), ".jpg", ".lock")

  defp converted_path do
    path = static_image_path()
    parts = Path.split(path)
    [filename | rest] = Enum.reverse(parts)
    ["converted-#{filename}" | rest]
    |> Enum.reverse()
    |> Path.join()
  end

  defp update_image_age(socket) do
    Process.send_after(self(), :update_image_age, @update_image_age_interval)
    assign_image_age(socket)
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
