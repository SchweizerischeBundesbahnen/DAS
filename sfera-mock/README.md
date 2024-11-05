# SFERA Mock

## Introduction
- solace
- for SFERA e2e tests of mobile app

## Getting-Started


## Scenarios

- Recipient: 0085
- drivingMode: Read-Only
- architecture: BoardAdviceCalculation
- connectivity: Connected

| Train number | Result                   |
|--------------|--------------------------|
| 4816         | Zürich HB - Aarau        |
| 7839         | Solothurn - Oberdorf SO  |
| 9999         | Fictional Bahnhof A - D1 |

TODO: 29137 Lenzburg - Luzern https://miro.com/app/board/uXjVKK4zJFk=/?moveToWidget=3458764596975113381&cot=14

## Add new Scenario
To create a new scenario some resources need to be added  
1. add journey profile named `SFERA_JP_<train number>` to `static_sfera_resources/jp`
2. add corresponding segment profiles named `SFERA_SP_<train number>_<sp id>` to `static_sfera_resources/sp`

