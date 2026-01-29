# DAS-Backend

## Introduction
SpringBoot application (needs PostgreSQL DB dockerized, s. [Database handling](Database.md))

## Getting-Started
### Run on localhost

1. Run a Docker Daemon (for e.g. by Windows: [Podman Desktop](https://podman-desktop.io/) which
   needs [WSL](https://learn.microsoft.com/en-us/windows/wsl/install))
2. Add environment variables (according to [application.yaml](src/main/resources/application.yaml) coming from values by API registries or vault) and specify concrete values
   - either by run configuration
   - or a {MODULE_WORKING_DIR}\.env file
   - Add `Maven-Settings -> Runner` -> `Environment variables` (missing URLs/secrets as in .env)
3. Run `DASBackendApplication`

Hints for Windows-Users:

* Enable podman-compose during installation
* If "docker compose" is not found:
  `Set-Alias -Name docker -Value "C:\Program Files\RedHat\Podman\podman.exe"`