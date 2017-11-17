# *Multi-App* Web Proxy using Docker-Compose, NGINX, and Let's Encrypt
Here's a fairly straightforward solution for how to setup multiple docker-compose applications that share the same NGINX proxy.

## Example
This is what we want to do. 2 docker-compose apps running on the same server, that share the same NGINX proxy.

```
         Server:
        |-------------------------------------------|
        |                                           |
        |           |--- App 1 (app1.example.com)   |
Client --- NGINX ---|                               |
        |           |--- App 2 (app2.example.com)   |
        |                                           |
        |-------------------------------------------|
```

## Problem
You can't include an NGINX proxy in each application becaue then you would have multiple proxies trying to listen on port 80/443. You can only have one.

Unfortunately, docker-compose doesn't have any built in support for "singleton" services that are shared across projects. I.e. there's no way to say: "Only create this service if it doesn't already exist."

## Solution
My solution is to split up the above example into 3 projects and share the same network across all projects.

### router
This is the web proxy (router). It sets up the nginx container, the jwilder nginx-gen container, and a letsencrypt companion. By default it will also create a network called "router_default" (see caveat below).

### apps
The only thing you have to change is to use the "router_default" network.

```
networks:
  default:
    external:
      name: router_default
```

## Usage
To start everything up, just run `docker-compose up` for each project (starting with `router`). I have a helper script that does this (`up.sh`)

## Caveat
The network name is generated based on the router's project name (which is by default the directory name). If you rename the project then you have to rename the app networks. 

An alternative solution would be to explicitly create your own network. For example:

```
docker network create my_router
```

Then, add the following to the **router project** (and to your apps):

```
networks:
  default:
    external:
      name: my_router
```

## References

Docker NGINX Proxy:  
https://github.com/jwilder/nginx-proxy

Let's Encrypt NGINX Proxy Companion:  
https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion

Docker-Compose Example:  
https://github.com/evertramos/docker-compose-letsencrypt-nginx-proxy-companion
