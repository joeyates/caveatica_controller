# Do not put configurations here if they depend on environment variables
# that may vary between compilations,
# put those configurations in 'config/runtime.exs'.

import Config

import_config "assets.exs"
import_config "endpoint.exs"
import_config "logger.exs"
import_config "phoenix.exs"
import_config "application.exs"
