> [!NOTE]
> This app is for testing and demo purpose only

# SFERA Mock

## Introduction

This application mocks TMS-VAD resp. fakes MQTT and waits for SFERA request topics (like train-number) to be received
from another source (like DAS-Client, DAS-Playground).

Capabilities:

- solace
- generates SFERA model out of `sfera_*.xsd`
- for SFERA e2e tests of DAS-Client (mobile App)

## Getting-Started

### Run on localhost

Follow the steps below before running `SferaMockApplication`.

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

Secret files are stored in [Keeper](https://www.keepersecurity.com/), make sure you get access to the DAS directory for
the SBB instance. Within the sfera_mock directory, you will find the `user_certificate.p12` file. Add it to
`src/main/resources` or adjust the `SOLACE_KEY_STORE_PATH` in `application-local.yaml` accordingly. Do the same for the
`localregulations.json` file.

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

### Run on localhost using podman compose up

As convenience, we add a `compose.yaml` file that sets up the local database and starts the spring boot application in a
separate container. After having access to secrets following the OpenBao setup and added the secret files to your
classpath, run `podman compose up`.

## Scenarios

- Recipient: 0085
- drivingMode: Read-Only
- architecture: BoardAdviceCalculation
- connectivity: Connected

see journeys [static_sfera_resources](src/main/resources/static_sfera_resources)

## Add new Scenario

To create a new scenario some resources need to be added

1. add a new directory named `<train number>_<optional comment>` in `src/main/resources/static_sfera_resources`
2. add a journey profile named `SFERA_JP_<train number>` to the directory
    1. to achieve dynamic timestamps you can use the following pattern
        - `9999-01-01-HH-MM-SSZ` for positive offsets
        - `0001-01-01-HH-MM-SSZ` for negative offsets
3. add corresponding segment profiles named `SFERA_SP_<train number>_<sp id>` to the directory
4. for events add `SFERA_Event_<train number>_<time after registration in ms>`