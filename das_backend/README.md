# Backend

## Introduction
SpringBoot application (needs PostgreSQL DB dockerized, s. [Database handling](Database.md))

## Getting-Started
### Run on localhost
1. Run a Docker Daemon (for e.g. by Windows: [Podman Desktop](https://podman-desktop.io/) needs VM 'WSL 2' from Microsoft Store)
2. Add environment variables (according to [application.yaml](src/main/resources/application.yaml) coming from values by API registries or vault) and specify concrete values
   - either by run configuration
   - or an .env file
3. Add Maven-Settings -> Runner -> Environment variables (missing URLs/secrets as in .env)
4. Run `DASBackendApplication`