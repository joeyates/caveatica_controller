# Caveatica Controller

A web application for monitoring and controlling Caveatica.

Opening and closing times are goverened by a calculation of
local sunrise and sunset times (see `CaveaticeController.Times`).

Each time is adjusted by an offset, so that opeining is a few minutes before sunrise
and closing is a few minutes after sunset.

These actions are scheduled jobs (see `CaveaticaController.Scheduler`) and
are reset every day via another job, set to run att midday (see `config/runtime.exs`).

# First Deployment

```sh
dokku apps:create $DOKKU_APP
dokku domains:set $DOKKU_APP $APP_DOMAIN
```

## Setup access to webcam images

```sh
dokku storage:ensure-directory $DOKKU_APP
dokku storage:mount $DOKKU_APP /var/lib/dokku/data/storage/$DOKKU_APP:/app/priv/static/data
```

```sh
dokku config:set --no-restart $DOKKU_APP \
  CAVEATICA_LATITUDE=48.85 \
  CAVEATICA_LONGITUDE=2.35 \
  CAVEATICA_TIMEZONE=Europe/Rome \
  CAVEATICA_OPEN_DURATION=3600 \
  CAVEATICA_CLOSE_DURATION=3600 \
  DATA_PATH=/app/priv/static/data \
  LIVE_VIEW_SALT=$LIVE_VIEW_SALT \
  PHX_HOST=$APP_DOMAIN \
  SECRET_KEY_BASE=$SECRET_KEY_BASE
```

The value of `DATA_PATH` should be an absolute path to a directory that
is writeable by the application and is web readable.

```sh
git remote add dokku dokku@$DOKKU_HOST:$DOKKU_APP
git push dokku
```

Get a TLS certificate

```sh
dokku ports:set $DOKKU_APP http:80:5000
dokku letsencrypt:set $DOKKU_APP email $DOMAIN_EMAIL
dokku letsencrypt:set $DOKKU_APP server staging
dokku letsencrypt:enable $DOKKU_APP
dokku letsencrypt:set $DOKKU_APP server
dokku letsencrypt:enable $DOKKU_APP
```

Authentication is via Dokku's basic auth plugin.

Add users via:

```sh
dokku http-auth:add-user $DOKKU_APP {{username}} {{password}}
```
