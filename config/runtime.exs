import Config

fetch_integer_env = fn var ->
  case System.get_env(var) do
    nil ->
      raise "environment variable #{var} is missing."

    value ->
      case Integer.parse(value) do
        {int_value, ""} ->
          int_value

        _ ->
          raise "environment variable #{var} must be an integer, got '#{value}'."
      end
  end
end

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :caveatica_controller, CaveaticaControllerWeb.Endpoint, secret_key_base: secret_key_base

data_path =
  System.get_env("DATA_PATH") ||
    raise """
    environment variable DATA_PATH is missing.
    """

config :caveatica_controller, :data_path, data_path

log_level = System.get_env("LOG_LEVEL")

if log_level do
  config :logger, level: String.to_existing_atom(log_level)
end

timezone =
  System.get_env("CAVEATICA_TIMEZONE") ||
    raise """
    environment variable CAVEATICA_TIMEZONE is missing.
    """

{longitude, ""} =
  "CAVEATICA_LONGITUDE"
  |> System.get_env()
  |> Float.parse()

{latitude, ""} =
  "CAVEATICA_LATITUDE"
  |> System.get_env()
  |> Float.parse()

open_duration = fetch_integer_env.("CAVEATICA_OPEN_DURATION")
close_duration = fetch_integer_env.("CAVEATICA_CLOSE_DURATION")

config :caveatica_controller,
  longitude: longitude,
  latitude: latitude,
  timezone: timezone,
  open_duration: open_duration,
  close_duration: close_duration

reset_time = %Crontab.CronExpression{minute: [0], hour: [12]}

config :caveatica_controller, CaveaticaController.Scheduler,
  timezone: "Europe/Rome",
  jobs: [
    reset: [schedule: reset_time, task: {CaveaticaController.Scheduler, :reset, []}]
  ]

case config_env() do
  :prod ->
    host =
      System.get_env("PHX_HOST") ||
        raise """
        environment variable PHX_HOST is missing.
        """

    port = String.to_integer(System.get_env("PORT", "4000"))
    phx_server = if System.get_env("PHX_SERVER"), do: true, else: false

    config :caveatica_controller, CaveaticaControllerWeb.Endpoint,
      url: [host: host, port: 443, scheme: "https"],
      http: [
        ip: {0, 0, 0, 0, 0, 0, 0, 0},
        port: port
      ],
      server: phx_server

  _ ->
    nil
end
