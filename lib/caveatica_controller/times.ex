defmodule CaveaticaController.Times do
  @moduledoc """
  Provides opening and closing times for CaveaticaController based on sunrise and sunset.
  """

  @close_offset_from_sunset_minutes 30
  @open_offset_from_sunrise_minutes -15

  def next_open!() do
    next_sunrise = next_sunrise!()
    DateTime.add(next_sunrise, @open_offset_from_sunrise_minutes, :minute)
  end

  def next_close!() do
    next_sunset = next_sunset!()
    DateTime.add(next_sunset, @close_offset_from_sunset_minutes, :minute)
  end

  defp next_sunrise!() do
    now = now()
    todays_sunrise = sunrise!(now)

    if now < todays_sunrise do
      todays_sunrise
    else
      tomorrow =
        now
        |> DateTime.to_date()
        |> Date.add(1)

      sunrise!(tomorrow)
    end
  end

  defp next_sunset!() do
    now = now()
    todays_sunset = sunset!(now)

    if now < todays_sunset do
      todays_sunset
    else
      tomorrow =
        now
        |> DateTime.to_date()
        |> Date.add(1)

      sunset!(tomorrow)
    end
  end

  defp timezone() do
    Application.fetch_env!(:caveatica_controller, :timezone)
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
    {:ok, date_time} = Astro.sunrise(location(), date, time_zone_resolver: &time_zone_resolver/1)
    date_time
  end

  defp sunset!(date) do
    {:ok, date_time} = Astro.sunset(location(), date, time_zone_resolver: &time_zone_resolver/1)
    date_time
  end

  defp time_zone_resolver(_date_time) do
    {:ok, timezone()}
  end
end
