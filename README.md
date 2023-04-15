# Caveatica Controller

Control the Caveatica Nerves application via a remote
web application.

# Deployment

Set up and deploy Dokku Phoenix app.

## Setup access to webcam images

```sh
dokku storage:mount $DOKKU_APP /home/dokku/caveatica/data:/app/priv/static/data
dokku config:set --no-restart $DOKKU_APP WEBCAM_IMAGE_PATH=/data/caveatica.jpg
```
