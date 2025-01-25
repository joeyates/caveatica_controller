defmodule CaveaticaController.Times do
  @moduledoc """
  Provides opening and closing times for CaveaticaController based on sunrise and sunset.
  """

  @close_offset_from_sunset 30 * 60 * 1000
  @open_offset_from_sunrise -15 * 60 * 1000

  def next_open() do
    now = now()
    todays_sunrise = sunrise!(now)

    if now < todays_sunrise do
      todays_sunrise + @open_offset_from_sunrise
    else
      tomorrow =
        now
        |> DateTime.to_date()
        |> Date.add(1)

      sunrise!(tomorrow) + @open_offset_from_sunrise
    end
  end

  def next_close() do
    now = now()
    todays_sunset = sunset!(now)

    if now < todays_sunset do
      todays_sunset + @close_offset_from_sunset
    else
      tomorrow =
        now
        |> DateTime.to_date()
        |> Date.add(1)

      sunset!(tomorrow) + @close_offset_from_sunset
    end
  end

  defp timezone() do
    Application.fetch_env!(:caveatica_controller, :caveatica_timezone)
  end

  defp location() do
    longitude = Application.fetch_env!(:caveatica_controller, :longitude)
    latitude = Application.fetch_env!(:caveatica_controller, :latitude)
    %Geo.Point{coordinates: {longitude, latitude}}
  end

  defp now() do
    DateTime.now!(timezone())
  end

  defp sunrise!(date) do
    {:ok, date_time} = Astro.sunrise(location(), date)
    date_time
  end

  defp sunset!(date) do
    {:ok, date_time} = Astro.sunset(location(), date)
    date_time
  end
end
