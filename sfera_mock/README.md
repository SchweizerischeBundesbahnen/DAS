> [!NOTE]  
> This app is for testing and demo purpose only

# SFERA Mock

## Introduction
This application mocks TMS-VAD resp. fakes MQTT and waits for SFERA request topics (like train-number) to be received from another source (like DAS-Client, DAS-Playground).

Capabilities:
- solace
- generates SFERA model out of `sfera_*.xsd`
- for SFERA e2e tests of DAS-Client (mobile App)

## Getting-Started
### Run on localhost
1. Add environment variables (according to [application.yaml](src/main/resources/application.yaml) and specify concrete values
   - by an .env file
   - (or by run configuration)
2. Add certificate-file to src/main/resources according to .env SOLACE_KEY_STORE_PATH
3. Run `SferaMockApplication`

## Scenarios

- Recipient: 0085
- drivingMode: Read-Only
- architecture: BoardAdviceCalculation
- connectivity: Connected

see journeys [static_sfera_resources](src/main/resources/static_sfera_resources)

## Add new Scenario
To create a new scenario some resources need to be added
1. add a new directory named `<train number>_<optional comment>` in `static_sfera_resources`
2. add a journey profile named `SFERA_JP_<train number>` to the directory
   1. to achieve dynamic timestamps you can use the following pattern
      - `9999-01-01-HH-MM-SSZ` for positive offsets
      - `0001-01-01-HH-MM-SSZ` for negative offsets
3. add corresponding segment profiles named `SFERA_SP_<train number>_<sp id>` to the directory
4. for events add `SFERA_Event_<train number>_<time after registration in ms>`