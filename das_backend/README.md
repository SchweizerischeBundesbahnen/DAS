# DAS-Backend

## Introduction
SpringBoot application backing the DAS ecosystem. It needs a PostgreSQL database — see
[Database handling](Database.md) for how schema changes are made and which SQL conventions to
follow once you start writing migrations.

## Getting-Started
### Run on localhost

1. Run a Docker Daemon (for e.g. by Windows: [Podman Desktop](https://podman-desktop.io/) which
   needs [WSL](https://learn.microsoft.com/en-us/windows/wsl/install))
2. Add environment variables (according to [application.yaml](src/main/resources/application.yaml) coming from values by API registries or vault) and specify concrete values
   - either by run configuration
   - or a {MODULE_WORKING_DIR}\.env file
   - Add `Maven-Settings -> Runner` -> `Environment variables` (missing URLs/secrets as in .env)
     or run maven with `-DskipSchemaDownload`
3. Start a local DB via `podman compose up` or `docker-compose up` (alternatively, this can be
   configured as a pre launch task in IntelliJ with Podman as server configured) — see
   [Database handling](Database.md) for how schema changes and migrations work once the DB is up
4. Run `DASBackendApplication`

Hints for Windows-Users:

* Enable podman-compose during installation
* If "docker compose" is not found:
  `Set-Alias -Name docker -Value "C:\Program Files\RedHat\Podman\podman.exe"`
