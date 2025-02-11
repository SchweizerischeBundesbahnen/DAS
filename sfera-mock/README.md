# SFERA Mock

## Introduction
- solace
- generates SFERA model out of `sfera_*.xsd`
- for SFERA e2e tests of mobile app

## Getting-Started
### Run on localhost
1. Add environment variables (according to [application.yaml](src/main/resources/application.yaml) and specify concrete values
   - either by run configuration
   - or an .env file
2. Run `SferaMockApplication`

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
3. add corresponding segment profiles named `SFERA_SP_<train number>_<sp id>` to the directory
4. for events add `SFERA_Event_<train number>_<time after registration in ms>`