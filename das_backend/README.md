# Backend

## Introduction
SpringBoot application (needs PostgreSQL DB dockerized, s. [compose.yaml](compose.yaml))

## Getting-Started
### Run on localhost
1. Run a Docker Daemon (for e.g. by Windows: [Podman Desktop](https://podman-desktop.io/) needs VM 'WSL 2' from Microsoft Store)
2. Add environment variables (according to [application.yaml](src/main/resources/application.yaml)) and specify concrete values
   - either by run configuration
   - or an .env file
3. Run `BackendApplication`

## Flyway
To make a database change Flyway is used as a migration tool. 
Add SQL script to [resources/db/migration](src/main/resources/db/migration) 
also see [versioned migrations](https://documentation.red-gate.com/fd/versioned-migrations-273973333.html).