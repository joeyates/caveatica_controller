defmodule CaveaticaControllerWeb.Gettext do
  @moduledoc """
  A module providing Internationalization with a gettext-based API.
  """

  use Gettext.Backend, otp_app: :caveatica_controller
end
