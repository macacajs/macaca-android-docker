# Macaca Android Docker Image

[![build status][travis-image]][travis-url]

[travis-image]: https://img.shields.io/travis/macacajs/macaca-android-docker.svg?style=flat-square
[travis-url]: https://travis-ci.org/macacajs/macaca-android-docker

## Macaca Tools Image

```bash
$ docker build . -t="macacajs/macaca-android-docker"
```

## Only For Build

```bash
$ docker build ./build -t="macacajs/macaca-android-docker-build"
```

## Usage

```bash
$ docker run -it --entrypoint="/bin/bash" macacajs/macaca-android-docker
```

```bash
$ android update sdk --proxy-host mirrors.neusoft.edu.cn --proxy-port 80 -s
```
