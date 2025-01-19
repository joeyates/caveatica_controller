import Config

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

open_env =
  System.get_env("OPEN_TIME") ||
    raise """
    environment variable OPEN_TIME is missing.
    """

close_env =
  System.get_env("CLOSE_TIME") ||
    raise """
    environment variable CLOSE_TIME is missing.
    """

open_time = Time.from_iso8601!(open_env)
close_time = Time.from_iso8601!(close_env)

open_cron =
  Crontab.CronExpression.Composer.compose(%Crontab.CronExpression{
    minute: [open_time.minute],
    hour: [open_time.hour]
  })

close_cron =
  Crontab.CronExpression.Composer.compose(%Crontab.CronExpression{
    minute: [close_time.minute],
    hour: [close_time.hour]
  })

config :caveatica_controller, CaveaticaController.Scheduler,
  timezone: "Europe/Rome",
  jobs: [
    {open_cron, {CaveaticaControllerWeb.Endpoint, :broadcast!, ["control", "close", %{}]}},
    {close_cron, {CaveaticaControllerWeb.Endpoint, :broadcast!, ["control", "open", %{}]}}
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
