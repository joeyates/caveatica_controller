import Config

config :caveatica_controller, CaveaticaControllerWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "KnqgFASFRxDZMOIVATOWUAMofOPRT+g4TCLPEltok7lpbiIT07cvxc9pXKHFPjTo",
  server: false

config :logger, level: :warning

config :phoenix, :plug_init_mode, :runtime
