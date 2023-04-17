defmodule CaveaticaControllerWeb.HomeLive.Index do
  use CaveaticaControllerWeb, :live_view

  @image_path Application.compile_env(:caveatica_controller, :webcam_image_path)
  @update_interval 5000 # ms

  @impl true
  def mount(_params, _session, socket) do
    {
      :ok,
      socket
      |> assign(:image_timestamp, nil)
      |> process_image()
    }
  end

  @impl true
  def handle_info(:update_image, socket) do
    {:noreply, process_image(socket)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, assign(socket, :page_title, "Caveatica")}
  end

  defp process_image(socket) do
    Process.send_after(self(), :update_image, @update_interval)
    timestamp = timestamp("./priv/static/#{@image_path}")
    if timestamp != socket.assigns.image_timestamp do
      epoch = DateTime.to_unix(timestamp)
      socket
      |> assign(:image_path, "#{@image_path}?time=#{epoch}")
      |> assign(:image_timestamp, timestamp)
    else
      socket
    end
  end

  defp timestamp(path) do
    stat = File.stat!(path)
    {erl_date, erl_time} = stat.mtime
    time = Time.from_erl!(erl_time)
    date = Date.from_erl!(erl_date)
    DateTime.new!(date, time, "Etc/UTC")
    |> DateTime.shift_zone!("Europe/Rome")
  end
end
