defmodule CaveaticaController.Images do
  alias CaveaticaController.Cldr.DateTime.Relative

  @server_timezone "Etc/UTC"
  @user_timezone "Europe/Rome"
  @maximum_image_dimension 320

  def receive(binary) do
    original_path = original_path()
    File.write!(original_path, binary)

    timestamp = timestamp(original_path)
    converted_path = converted_path()
    :ok = rotate_90(original_path, converted_path)
    epoch = DateTime.to_unix(timestamp)
    image_path = "/data/converted.jpg?time=#{epoch}"
    age = image_age(timestamp)
    {:ok, image_path, age}
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

  defp image_age(timestamp) do
    ago = Relative.to_string!(timestamp)
    "Image created #{ago} (#{timestamp})"
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
