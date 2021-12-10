# Dapr Offline Installer
A standalone dapr installation for offline, air-gapped, or disconnected use-cases.

## Dapr Version
This version of the tool install dapr version 1.5.1.

## Limitations
This version of the tool only supports dapr slim init installations on Linux ARM64 devices.

Additionally, this tool assumes that docker is installed and that the following images are already present in the local docker image registry:
- daprio/dapr:1.5.1
- redis:latest
- openzipkin/zipkin:latest

If these images are not already present locally, docker will attempt to pull these across the internet from thier respective public repositories as part of installation.

## Usage
``` bash
bash ./install.sh
```
