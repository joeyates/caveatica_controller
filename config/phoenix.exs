import Config

config :phoenix, :json_library, Jason

case config_env() do
  :dev ->
    config :caveatica_controller, dev_routes: true
    config :phoenix, :stacktrace_depth, 20
    config :phoenix, :plug_init_mode, :runtime
  :test ->
    config :phoenix, :plug_init_mode, :runtime
  _ ->
    nil
end

