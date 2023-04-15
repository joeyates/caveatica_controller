import Config

config :caveatica_controller, CaveaticaControllerWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: CaveaticaControllerWeb.ErrorHTML, json: CaveaticaControllerWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: CaveaticaController.PubSub,
  live_view: [signing_salt: "Z4GRDVur"]

config :esbuild,
  version: "0.14.41",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :tailwind,
  version: "3.2.4",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

webcam_image_path =
  System.get_env("WEBCAM_IMAGE_PATH") ||
    raise """
    environment variable WEBCAM_IMAGE_PATH is missing.
    """

config :caveatica_controller, :webcam_image_path, webcam_image_path

import_config "#{config_env()}.exs"
