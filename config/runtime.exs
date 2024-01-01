import Config

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :caveatica_controller, CaveaticaControllerWeb.Endpoint,
  secret_key_base: secret_key_base

webcam_image_path =
  System.get_env("WEBCAM_IMAGE_PATH") ||
    raise """
    environment variable WEBCAM_IMAGE_PATH is missing.
    """

config :caveatica_controller, :webcam_image_path, webcam_image_path

case config_env() do
  :prod ->

    host = System.get_env("PHX_HOST") ||
      raise """
      environment variable PHX_HOST is missing.
      """
    port = String.to_integer(System.get_env("PORT") || "4000")
    phx_server = if System.get_env("PHX_SERVER"), do: true, else: false

    config :caveatica_controller, CaveaticaControllerWeb.Endpoint,
      url: [host: host, port: 443, scheme: "https"],
      http: [
        ip: {0, 0, 0, 0, 0, 0, 0, 0},
        port: port
      ],
      secret_key_base: secret_key_base,
      server: phx_server

  _ ->
    nil
end
