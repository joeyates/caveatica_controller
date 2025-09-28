defmodule CaveaticaController.Images do
  @maximum_image_dimension 320

  def receive(binary) do
    timestamp = CaveaticaController.Times.caveatica_datetime()

    original_path = original_path()
    File.write!(original_path, binary)

    converted_path = converted_path()
    :ok = rotate_90(original_path, converted_path)
    epoch = DateTime.to_unix(timestamp)
    image_path = "/data/converted.jpg?time=#{epoch}"
    {:ok, image_path, timestamp}
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

  def rotate_90(from, to) do
    System.cmd(
      "convert",
      [
        from,
        "-rotate",
        "90",
        "-gravity",
        "center",
        "-crop",
        "#{@maximum_image_dimension}x#{@maximum_image_dimension}",
        to
      ]
    )

    :ok
  end
end
