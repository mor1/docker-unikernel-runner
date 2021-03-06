# Docker unikernel runner [![Build Status](https://travis-ci.org/mato/docker-unikernel-runner.svg?branch=master)](https://travis-ci.org/mato/docker-unikernel-runner)

Docker-unikernel-runner is a platform for experimenting with using Docker
components to _build_, _distribute_ and _run_ unikernels[[1]](#footnote1). It
provides a base image for unikernel images to inherit from, glue code to
integrate with (among other things) Docker networking, and a minimal runtime to
actually launch the unikernel (currently implemented using QEMU/KVM).

## TL;DR

WOPR demo:

    docker run --rm -ti \
        --device /dev/kvm:/dev/kvm \
        --device /dev/net/tun:/dev/net/tun \
        --cap-add NET_ADMIN \
        mato/unikernel-wopr

Telnet to `<container-ip>`, port 4096. Logon as `Joshua`.

Historic fun fact: WOPR was written as a custom program for testing a networked
service on a Rumprun unikernel in August 2013, before POSIX support was
implemented. The current version has been ported to run on top of POSIX
interfaces.

Mathopd webserver:

    docker run --rm -ti \
        --device /dev/kvm:/dev/kvm \
        --device /dev/net/tun:/dev/net/tun \
        --cap-add NET_ADMIN \
        mato/unikernel-mathopd

Browse to `http://<container-ip>/`.

## Building unikernels using this image

To use this image as a base, a child image inherits `FROM
mato/unikernel-runner` and must adhere to the following structure:

    /unikernel/unikernel.bin
    /unikernel/config.json
    /unikernel/fs/<volume>.img

* `unikernel.bin` is the unikernel binary[[1]](#footnote1).
* `config.json` is an _optional_ JSON configuration to be passed to the
  unikernel. The configuration must follow the work in progress "Rumprun
  unikernel configuration" [specification](https://github.com/rumpkernel/rumprun/blob/mato-wip-rumprun-config/doc/config.md) (see **NOTE** below) and, in addition:
  * must not include a `net` object, this will be generated by unikernel-runner.
  * if it includes a `mount` object, must not define any mountpoints using
    `/dev/ld*` block devices, these are generated by unikernel-runner.
* Each file under `/unikernel/fs` is assumed to be a filesystem image.
  Unikernel-runner will automatically generate configuration to mount
  `<volume>.img` as `/<volume>` in the unikernel.

A child image must not rely on the existence of, or modify/add any files to
the image outside of the `/unikernel` subtree.

Refer to `Dockerfile.wopr`, `Dockerfile.wopr-build`, `Dockerfile.mathopd` and
`Dockerfile.mathopd-build` for examples of Dockerfiles which build unikernels
using `unikernel-runner` as a base image.

**NOTE**: The work in progress rumprun configuration parser used by
unikernel-runner has not yet been merged into rumprun master. When building
unikernels for unikernel-runner be sure to use a toolchain built off the
`mato-wip-rumprun-config` branch, also available as the
`mato/rumprun-toolchain-hw-x86_64:wip-rumprun-config` image on Docker Hub.

## Running unikernels built using this image

Start the container as you would any other Docker container, with the
following additional options:

    --device /dev/kvm:/dev/kvm
    --device /dev/net/tun:/dev/net/tun
    --cap-add NET_ADMIN

If you do not pass a `/dev/kvm` into the container, the unikernel will be
launched using software emulation only.

`CAP_NET_ADMIN` and access to `/dev/net/tun` are required for unikernel-runner
to be able to wire L2 network connectivity from Docker to the unikernel guest.
Unikernel-runner invokes the included minimal QEMU binary as a _non root_ user.
There are *no* other binaries present in the base image (i.e. it is built `FROM
scratch`).

## Developing unikernel-runner

The build process for unikernel-runner is containerized. However, due to the
need to use intermediate containers to separate the different toolchains it
cannot be run as a single container.

Thus, you will need both `docker` and `make` available in your development
environment. To build everything from source, just run `make`.

<a name="footnote1">[1]</a> Unikernel-runner currently supports only Rumprun
unikernels built for `x86_64-rumprun-netbsd` and baked for the `hw_virtio`
configuration.

