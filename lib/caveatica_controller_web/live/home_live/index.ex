defmodule CaveaticaControllerWeb.HomeLive.Index do
  use CaveaticaControllerWeb, :live_view

  @caveatica_node :"caveatica@127.0.0.1"
  @this_node :"controller@127.0.0.1"
  @cookie :caveatica_cookie
  @static_image_path Application.compile_env(:caveatica_controller, :webcam_image_path)
  @update_interval 5000 # ms
  @server_timezone "Etc/UTC"
  @user_timezone "Europe/Rome"
  @maximum_image_dimension 320

  @impl true
  def mount(_params, _session, socket) do
    Node.start(@this_node)
    Node.set_cookie(@cookie)
    {
      :ok,
      socket
      |> check_availability()
      |> assign(:image_timestamp, nil)
      |> process_image()
    }
  end

  @impl true
  def handle_event("nudge-open", _params, socket) do
    Node.spawn(@caveatica_node, Caveatica, :open, [30])
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
  def handle_params(_params, _url, socket) do
    {:noreply, assign(socket, :page_title, "Caveatica")}
  end

  defp check_availability(socket) do
    Process.send_after(self(), :check_availability, @update_interval)
    case Node.ping(@caveatica_node) do
      :pong ->
        assign(socket, :available, true)
      :pang ->
        assign(socket, :available, false)
    end
  end

  defp process_image(socket) do
    Process.send_after(self(), :update_image, @update_interval)
    original_relative_path = "./priv/static/#{@static_image_path}"
    timestamp = timestamp(original_relative_path)
    if timestamp != socket.assigns.image_timestamp do
      converted_path = converted_path(@static_image_path)
      converted_relative_path = "./priv/static/#{converted_path}"
      :ok = rotate_90(original_relative_path, converted_relative_path)
      epoch = DateTime.to_unix(timestamp)
      socket
      |> assign(:image_path, "/#{converted_path}?time=#{epoch}")
      |> assign(:image_timestamp, timestamp)
    else
      socket
    end
  end

  defp converted_path(path) do
    parts = Path.split(path)
    [last | rest] = Enum.reverse(parts)
    ["converted-#{last}" | rest]
    |> Enum.reverse()
    |> Path.join()
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
