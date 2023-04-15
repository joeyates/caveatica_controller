import Config

config :caveatica_controller, CaveaticaControllerWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "9mysF6iGofC/zhOgnSRcbAveypKhZ4Ak7/YYJzc1xMhzEcilzF5PQ1qHjx3VayVB",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]}
  ]

config :caveatica_controller, CaveaticaControllerWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/caveatica_controller_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

config :caveatica_controller, dev_routes: true

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :phoenix, :plug_init_mode, :runtime
