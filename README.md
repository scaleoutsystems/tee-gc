# Gramine Container for FEDn
This repository defines a [Gramine](https://github.com/gramineproject/gramine)-enabled container for FEDn. The container is intended to be used for running FEDn components on the [Intel SGX](https://www.intel.com/content/www/us/en/developer/tools/software-guard-extensions/overview.html) platform.

## Table of Contents
- [Gramine Container for FEDn](#gramine-container-for-fedn)
  - [Table of Contents](#table-of-contents)
  - [Quickstart](#quickstart)
  - [Running individual components](#running-individual-components)
  - [Known issues](#known-issues)

## Quickstart
For demonstration purposes you can run the whole stack on a single SGX machine using [docker-compose](https://docs.docker.com/compose). First clone and locate in the current repo and then run the following command.

```bash
docker-compose up -d
```
> **Notes** 
> 1. You may need to login into Scaleout's GitHub registry to access ghcr.io/scaleoutsystems/tee-gc/fedn:latest
> 2. The usual FEDn ports should be exposed on the machine. You can use these ports to access the UI.

## Running individual components
To run reducer, combiner and client individually you can simply run the following Docker command:

```bash
docker run ghcr.io/scaleoutsystems/tee-gc/fedn -v config/settings-reducer.yaml:/app/config/settings-reducer.yaml --net=host --privileged -d reducer # start the reducer
docker run ghcr.io/scaleoutsystems/tee-gc/fedn -v config/settings-combiner.yaml:/app/config/settings-combiner.yaml --net=host --privileged -d combiner # start the combiner
docker run ghcr.io/scaleoutsystems/tee-gc/fedn -v config/settings-client.yaml:/app/config/settings-client.yaml --net=host --privileged -d client # start the client
```

## Known issues
- All the services run on `localhost` with the Docker containers attaching straight to the host network.
- The container is not setup to run the compute package in the enclave (deps are missing).