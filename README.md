# Caveatica Controller

A web application for monitoring and controlling Caveatica.

# First Deployment

Set up and deploy Dokku Phoenix app.

## Setup access to webcam images

```sh
dokku storage:mount $DOKKU_APP /home/dokku/caveatica/data:/app/priv/static/data
dokku config:set --no-restart $DOKKU_APP WEBCAM_IMAGE_PATH=data/caveatica.jpg
```

The value of WEBCAM_IMAGE_PATH should be the path relative to the 'static'
directory.

## Give Access to Host Networking

We need acces to epmd (port 4369) and caveatica itself (port 5555).

The container will run with host networking, so the Phoenix app's port must
not clash with any application running on the host.

```sh
dokku docker-options:add $DOKKU_APP deploy "--net=host"
```

# Deployment

As the app uses host networking, its port (5000) is actualloy the host's port.
For this reason, 2 instances of the app cannot run at the same time.
As Dokku starts 'upcoming' instances before stopping currently running
instances, we get an `:eaddrinuse` error.

For this reason, it is necessary to stop the app before
re-deploying.

```sh
dokku ps:stop $DOKKU_APP
git push dokku
```
