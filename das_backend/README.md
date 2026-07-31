# DAS-Backend

Provides additional services for the [DAS-Client](das_client/README.md) which are not covered by SFERA (for e.g.
additional Cargo data). Some configuration and master data may be configured
by [DAS-Admin-Tool](das_admin_tool/README.md).

Important:

* This component is not a **RU DAS-TS** implementation, but offers additional related services.

## Introduction

SpringBoot application backing the DAS ecosystem. It needs a PostgreSQL database — see
[Database handling](Database.md) for how schema changes are made and which SQL conventions to follow once you start
writing migrations.

## Getting-Started

### Run on localhost

Follow the steps below before running the `DASBackendApplication`.

#### Accessing secrets and sensitive information using OpenBao

Secrets and sensitive information is stored in the SBB hosted
[OpenBao](https://openbao.org/) instance.

Take these steps to make this information locally available:

1. Install the OpenBao CLI by following the official
   [Installing OpenBao](https://openbao.org/docs/install/) guide
2. Make sure the installed binary is on your PATH. Check that running `bao --version` succeeds in your shell
3. Set the `BAO_ADDR` variable in your shell to `https://vault-nonprod.sbb.ch`:
    * Windows: `$env:BAO_ADDR="https://vault-nonprod.sbb.ch"`
    * Unix: `$ export BAO_ADDR="https://vault-nonprod.sbb.ch"`
4. Authenticate to the vault by running `bao login -method=oidc` - this will open a SSO session in your default browser
5. Make sure a token is fetched by running `bao token lookup` - the token should have the necessary policies attached to
   access the secrets

#### Maven Schema Download

Some of the schemas for maven for source generation are protected. To make them accessible, you need to:

1. Make sure you have a bao token by following the steps from above
2. Run `bao kv get kv/DSO-BPS/driver-advisory-system/backend/maven`
3. Make the displayed secrets available to maven via environment variables
    * IntelliJ: `Maven-Settings -> Runner` -> `Environment variables`

Alternatively, you can run maven with `-DskipSchemaDownload` to skip this step.

#### Local Database

A local database is required to run the backend. We recommend running it as a containerized application. The setup
uses [Podman](https://podman.io/get-started) to get running.

1. Run a container engine (for e.g. by Windows: [Podman Desktop](https://podman-desktop.io/) which
   needs [WSL](https://learn.microsoft.com/en-us/windows/wsl/install))
2. Start a local DB via `podman compose up` (alternatively, this can be configured as a pre-launch task in IntelliJ with
   Podman as server configured)
3. see [Database handling](Database.md) for how schema changes and migrations work once the DB is up

Hints for Windows:

* Enable podman-compose during installation
* If "docker compose" is not found:
  `Set-Alias -Name docker -Value "C:\Program Files\RedHat\Podman\podman.exe"`

With all these steps completed, you are ready to run `DASBackendApplication`.
