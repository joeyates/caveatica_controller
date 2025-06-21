# Caveatica Controller

A web application for monitoring and controlling Caveatica.

Opening and closing times are goverened by a calculation of
local sunrise and sunset times (see `CaveaticeController.Times`).

Each time is adjusted by an offset, so that opeining is a few minutes before sunrise
and closing is a few minutes after sunset.

These actions are scheduled jobs (see `CaveaticaController.Scheduler`) and
are reset every day via another job, set to run att midday (see `config/runtime.exs`).

# First Deployment

Set up and deploy Dokku Phoenix app.

```sh
git remote add dokku dokku@$DOKKU_HOST:$DOKKU_APP
```

Set opening and closing parameters

```sh
dokku config:set --no-restart $DOKKU_APP \
  CAVEATICA_LATITUDE=48.85 \
  CAVEATICA_LONGITUDE=2.35 \
  CAVEATICA_TIMEZONE=Europe/Paris \
  CAVEATICA_OPEN_DURATION=3600 \
  CAVEATICA_CLOSE_DURATION=3600
```

## Setup access to webcam images

```sh
dokku storage:ensure-directory "$DOKKU_APP"
dokku storage:mount "$DOKKU_APP" "/var/lib/dokku/data/storage/$DOKKU_APP:/app/priv/static/data"
dokku config:set --no-restart $DOKKU_APP DATA_PATH=/app/priv/static/data
```

The value of `DATA_PATH` should be an absolute path to a directory that
is writeable by the application and is web readable.
