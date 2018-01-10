## Description

This is an expanded version of [stack-docker](https://github.com/elastic/stack-docker).

The biggest change from the official version is that is doesn't include Beats and it is fully configured for X-Pack.

What's with the name?
---------------------

The first part of the name is referring to a [Conex Box](https://en.wikipedia.org/wiki/Conex_box), which is an early form of a shipping container. Conex~Container => Container=Docker.

Moose is referring to the Elastic Stack without calling it ELK, because [ELK is a dated term](https://www.elastic.co/blog/heya-elastic-stack-and-x-pack). Moose are in the same category as Elk, so I think it works :smile:.

Just imagine a Moose poking it's head out of a Conex Box. Maybe some day I'll get a sticker made of that.

## Supported Docker versions

I am running Docker 17.09.0-ce with Docker Compose 1.17.1

## Getting Started

Setup your storage. It's outside of the scope of this readme, but I recommend using SSD storage and that you [update your storage driver](https://docs.docker.com/engine/userguide/storagedriver/device-mapper-driver/)

Create an external network and grab the subnet for future reference:
```
docker network create elastic

docker network inspect elastic
```

You'll need to use the gateway address listed if you want to talk from the containers to the host. I use that when I'm reading from a Kafka topic on the host.

**To run with X-Pack basic features:**

```
docker-compose -f docker-compose.yml -p conex-moose up -d
```

**To run with X-Pack platinum features:**

Open [xpack/.env](xpack/.env) in your favorite editor (Vim, duh) and change the passwords to something of your own invention. Then, fire it up:

```
cd xpack

# This piece only needs to be run once to generate your SSL certificates
docker-compose -f create_certs.yml up

docker-compose -f ../docker-compose.yml -f platinum-overrides.yml -p conex-moose up -d
```

## Roadmap

I would really like to figure out a clean way to use the scale feature of Docker. The current blocker is that each Elasticsearch container needs a persistent volume and I haven't found a good way to pass in a variable, such as the container name, to make the volume name unique.

At some point I might play with doing this in something like OpenShift, but I mainly wanted something I could get running quickly and go from there.
