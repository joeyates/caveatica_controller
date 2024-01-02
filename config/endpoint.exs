import Config

config :caveatica_controller, CaveaticaControllerWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: CaveaticaControllerWeb.ErrorHTML, json: CaveaticaControllerWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: CaveaticaController.PubSub,
  live_view: [signing_salt: "Z4GRDVur"]

case config_env() do
  :dev ->
    config :caveatica_controller, CaveaticaControllerWeb.Endpoint,
      http: [ip: {0, 0, 0, 0}, port: 4000],
      check_origin: false,
      code_reloader: true,
      debug_errors: true,
      secret_key_base: "9mysF6iGofC/zhOgnSRcbAveypKhZ4Ak7/YYJzc1xMhzEcilzF5PQ1qHjx3VayVB",
      watchers: [
        esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]},
        tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]}
      ],
      live_reload: [
        patterns: [
          ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
          ~r"priv/gettext/.*(po)$",
          ~r"lib/caveatica_controller_web/(controllers|live|components)/.*(ex|heex)$"
        ]
      ]

  :prod ->
    config :caveatica_controller, CaveaticaControllerWeb.Endpoint,
      cache_static_manifest: "priv/static/cache_manifest.json"

  :test ->
    config :caveatica_controller, CaveaticaControllerWeb.Endpoint,
      http: [ip: {127, 0, 0, 1}, port: 4002],
      secret_key_base: "KnqgFASFRxDZMOIVATOWUAMofOPRT+g4TCLPEltok7lpbiIT07cvxc9pXKHFPjTo",
      server: false
end
