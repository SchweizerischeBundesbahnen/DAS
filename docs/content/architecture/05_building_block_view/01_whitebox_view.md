---
title: 5.1 Whitebox View
draft: true
cascade:
  type: docs
---

## Blueprint by UIC "IRS-90940:2022 Ed.2" Specification
Some abbreviations from the Specification:
* C-DAS-O: Connected DAS with OnBoard intelligence
* S-DAS: Standalone DAS
* DAS-OB: DAS OnBoard
* DAS-TS: DAS Trackside
* G2B: Ground to Board
* B2G: Board to Ground
* IM: Infrastructure Manager
* RU: Railway Undertaking

![SFERA Architecture: Data exchange layer (chapter 6.1)](IRS-90940_ed2_SFERA-DataExchangeLayer.png)

**This project is all about the `DAS On-Board` component** implemented by SBB:
![DAS On-Board](DAS_On-Board.png)

At SBB the **IM-Train setup** respectively `IM DAS-TS` to many `RU DAS-OB[n]` instances by `MQTT` variant is chosen by design-decision:
![SFERA Architecture: DAS RU/IM components and setup](IRS-90940_ed2_DAS_RU-IM_setup.png)

The mode at handshake time between `IM-DAS-TS` and `RU DAS-OB` is of type **C-DAS-O**:
![DAS On-Board](IRS-90940_ed2_C-DAS.png)

## SBB Component Architecture
The architecture of the SBB implementation of `DAS-Client` and `SFERA protocol` keeps exactly to the blueprint variant **IM-Train setup** by IRS-90940 above, where the following naming is used:  
| IRS Component | SBB Component |  
| ------------- | ------------- |  
| IM DAS-TS     | TMS::VAD      |  
| RU DAS-OB     | DAS-Client    |  

Other blue components represent a best known goal in the near future and may be concretised over time:
![Building blocks (whitebox overview)](das-buildingBlocks_whiteboxOverview.png)
