# Caveatica Controller

A web application for monitoring and controlling Caveatica.

# First Deployment

Set up and deploy Dokku Phoenix app.

```sh
git remote add dokku dokku@$DOKKU_HOST:$DOKKU_APP
```

## Setup access to webcam images

```sh
dokku storage:ensure-directory "$DOKKU_APP"
dokku storage:mount "$DOKKU_APP" "/var/lib/dokku/data/storage/$DOKKU_APP:/data"
dokku config:set --no-restart $DOKKU_APP DATA_PATH=/data
```

The value of `DATA_PATH` should be an absolute path to a directory that
is writeable by the application.
