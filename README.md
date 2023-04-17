# Caveatica Controller

A web application for monitoring and controlling Caveatica.

# Deployment

Set up and deploy Dokku Phoenix app.

## Setup access to webcam images

```sh
dokku storage:mount $DOKKU_APP /home/dokku/caveatica/data:/app/priv/static/data
dokku config:set --no-restart $DOKKU_APP WEBCAM_IMAGE_PATH=data/caveatica.jpg
```

The value of WEBCAM_IMAGE_PATH should be the path relative to the 'static'
directory.
