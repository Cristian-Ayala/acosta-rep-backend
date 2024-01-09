<p align="center">
  <a href="http://nestjs.com/" target="blank"><img src="https://nestjs.com/img/logo-small.svg" width="200" alt="Nest Logo" /></a>
</p>

# Description

Nestjs project for repository [Acosta Repuestos Front-End](https://github.com/Cristian-Ayala/acosta-repuesto-vite). It is a project to save and serve images that are uploaded in frontend project.

# Requirement
Having an Auth0 account and set up a project

1. Add action flow to login:
First action: (Check if configured)
exports.onExecutePostLogin = async (event, api) => {
  const allowedRoles = (event.authorization && event.authorization.roles) || [];
  if(allowedRoles.length) return;
  api.redirect.sendUserTo(`${event.transaction.redirect_uri}/logout`);
};

Second action: (Inject Hasura Claims)
exports.onExecutePostLogin = async (event, api) => {
  const allowedRoles = (event.authorization && event.authorization.roles) || [];
  const metadata = event.user.app_metadata || {};

  if (!allowedRoles.length || !event.user.email_verified)
    api.access.deny("Email not verified");
  api.idToken.setCustomClaim("https://hasura.io/jwt/claims", {
    "x-hasura-default-role": allowedRoles[0],
    "x-hasura-allowed-roles": allowedRoles,
    "x-hasura-user-id": event.user.user_id,
    "x-hasura-user-email": event.user.email,
  });
  api.idToken.setCustomClaim("metadata", metadata);
};

2. Add roles to users
gerente_area or seller

3. Add App Metadata (app_metadata), under Details tab.
{
  "sucursal": [
    "Santa Ana",
    "Metapan"
  ]
}

# Installation

1. Create and .env file and modify it with your own data. As an example there is an env.properties.
> (You have to be on root project path)

2. Read what service you are going to use and prepare what's needed.

3. Run the docker-compose.yml file of your preference. Use whatever you need. Examples:
```bash
$ docker compose -f SET_UP/BACKEND+POSTGRESQL/docker-compose.yml --env-file ./.env up -d
```

```bash
$ docker compose -f SET_UP/BACKEND+POSTGRESQL+NGINX/docker-compose.yml --env-file ./.env up -d
```
Stop and remove containers
```bash
$ docker compose -f SET_UP/BACKEND+POSTGRESQL+HASURA/docker-compose.yml down
```

(Optional)
4. Download [Images](https://github.com/acostarep/images-backend) and paste them on BACK_UPS/uploads folder
```bash
$ git clone https://github.com/acostarep/images-backend
$ mv images-backend/* /PATH/OF/THIS/PROJECT/BACK_UPS/uploads
$ rm -rf images-backend
```

## RUN BACKEND ALONE

You must already have postgresql and if you want, nginx to expose your the endpoints. If everything is consumed local, then you dont need to expose them.

```bash
$ docker build -t acosta-rep-backend:1.0.0 -t acosta-rep-backend:latest .
$ docker run -d --env-file .env -p 3000:3000 -v ./src/KEEP_TRACK:/usr/app/src/KEEP_TRACK/:rw acosta-rep-backend:1.0.0
```

## ADD POSTGRESQL SERVICE

> [!IMPORTANT]
> Open port 5432 from your server (or port where postgres is running)

If you want to reload the schema you got to delete the data volume.

> [!WARNING] > [Postgresql docker image](https://hub.docker.com/_/postgres/): scripts in /docker-entrypoint-initdb.d are only run if you start the container with a data directory that is empty; any pre-existing database will be left untouched on container startup. One common problem is that if one of your /docker-entrypoint-initdb.d scripts fails (which will cause the entrypoint script to exit) and your orchestrator restarts the container with the already initialized data directory, it will not continue on with your scripts.

```bash
$ docker volume ls
$ docker volume rm <volume_name>
```

## ADD NGINX SERVICE AND LETSNCRYPT

> [!IMPORTANT]
> Open ports 80 and 443 from your server

You must have a domain or subdomain pointing to your server, to expose your endpoint.
SSL certification are created with certbot, a public IP address needs to be set in your server.

## ADD HASURA SERVICE

Remember to set the env variables.

# Useful commands

```bash
$ docker ps -a # list all the currently running containers
$ docker exec -it <container_name> /bin/sh # run commands inside container
$ scp -r <YOUR_PATH> <USER_IN_SERVER>@<PUBLIC_IP>:<SERVER_PATH> # copy files from --> to (local to server or viseverda changing the order)
```

# Create a postgresql backup if running on a docker container

```bash
$ docker exec -t <container_name> pg_dump -U <user_name> -d postgres > backup.sql
$ docker cp <container_name>:/backup.sql ./YOUR_PATH/
```

# Running the app

Remember to add an .env file and add all variables listed in env.properties

```bash
# development
$ yarn run start

# watch mode
$ yarn run start:dev

# production mode
$ yarn run start:prod
```
