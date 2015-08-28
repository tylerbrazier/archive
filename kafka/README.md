kafka
=====
Instructions and resources for setting up a Kafka server running in Docker.

This was all part of a project we had started at a place I worked at but it
was abandoned. Rather than throwing all of this code away, I've decided to keep
it around in the archive.

TODO
----
This project is currently unfinished. At this point, the scripts are able to
build the docker images, start and stop boot2docker with the running containers,
and clear all existing images and containers.

What needs to happen next is to get Kafka to communicate with Zookeeper.
Right now, if you start up boot2docker, run the containers, and check the
output of the kafka container using `docker logs <id of kafka container>` you'll
see that kafka isn't able to connect to zk and eventually times out, exiting
the container. The problem is that right now it's set up to connect to zk on its
localhost. [This page](https://docs.docker.com/articles/networking/) explains
how docker handles networking for its containers. The next step is to have the
docker server start with a static address for the `docker0` interface.
Then we have kafka point to that address for accessing zk instead of localhost.
It seems that we can add the following line to `/var/lib/boot2docker/profile`
to have docker start with the static address:

    EXTRA_ARGS="$EXTRA_ARGS --bip='172.17.42.2/16'"

The address here is arbitrary but it's within the range documented on the
networking page and a few tests showed that it works.
The profile is read by `/etc/init.d/docker` when starting the docker server.
Probably the "best" way to set this would be to define a `b2d_local_ip` (or
something similar) property in `configuration.txt` that will be set in
`server.properties` using the `server.properties.template` as well as in the
`/var/lib/boot2docker/profile` file (possibly like how the other
`/var/lib/boot2docker/bootlocal.sh` persistent file is created in `setup.sh`).

Install (Windows)
-----------------
Download docker-install.exe from
https://github.com/boot2docker/windows-installer/releases/tag/v1.3.2

Run the installer.
next > next > make sure all checkboxes are checked (full installation) then
next > next > next > install > finish.

Edit `configuration.txt` and run `setup.sh`.

Related Links
-------------

* Docker https://docs.docker.com/userguide/
* boot2docker https://github.com/boot2docker/boot2docker/blob/v1.3.2/README.md
* b2d FAQ https://github.com/boot2docker/boot2docker/blob/v1.3.2/doc/FAQ.md
* Zookeeper 3.4.6 https://zookeeper.apache.org/doc/r3.4.6/
* Kafka http://kafka.apache.org/documentation.html
