# Unikernel runner

## TL;DR

WOPR demo:

    docker run --rm -ti \
        --device /dev/kvm:/dev/kvm \
        --device /dev/net/tun:/dev/net/tun \
        --cap-add NET_ADMIN \
        mato/unikernel-wopr

Telnet to `<container-ip>`, port 4096.

Mathopd web server:

    docker run --rm -ti \
        --device /dev/kvm:/dev/kvm \
        --device /dev/net/tun:/dev/net/tun \
        --cap-add NET_ADMIN \
        mato/unikernel-mathopd

Browse to `http://<container-ip>/`.

## Building unikernels using this image

Unikernel-runner provides a base image for running rumprun unikernels as Docker
containers using KVM, fully integrated with Docker networking.

To use this image as a base, a child image inherits `FROM
mato/unikernel-runner` and must adhere to the following structure:

    /unikernel/unikernel.bin
    /unikernel/config.json
    /unikernel/fs/<volume>.img

* `unikernel.bin` is the unikernel binary. Only the rumprun `hw/x86_64`
  platform is currently supported, and the image must be baked using the
  `hw_virtio` configuration.
* `config.json` is an _optional_ JSON configuration to be passed to the
  unikernel. The configuration must follow the work in progress "Rumprun
  unikernel configuration" [specification](https://github.com/rumpkernel/rumprun/blob/mato-wip-rumprun-config/doc/config.md) (see **NOTE** below) and, in addition:
  * must not include a `net` object, this will be generated by unikernel-runner.
  * if it includes a `mount` object, must not define any mountpoints using
    `/dev/ld*` block devices, these are generated by unikernel-runner.
* Each file under `/unikernel/fs` is assumed to be a filesystem image.
  Unikernel-runner will automatically generate configuration to mount
  `imagename.img` as `/imagename` in the unikernel.

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

If you do not pass a `/dev/kvm` into the container, the unikernel will be run
using software emulation only.

## Developing unikernel-runner

The build process for unikernel-runner is containerized. However, due to the
need to use intermediate containers to separate the different toolchains it
cannot be run as a single container.

Thus, you will need both `docker` and `make` available in your development
environment. To build everything from source, just run `make`.
