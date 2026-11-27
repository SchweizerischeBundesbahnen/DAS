---
title: 1.3 Stakeholders
draft: true
cascade:
  type: docs
---

## Organizations

| Stakeholder                                                                | Role and expectations                                                                                                                                                                                                                                       |
|:---------------------------------------------------------------------------|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Cooperation partners: SBB Passenger Traffic, SBB Cargo, SOB, BLS           | Initiated DAS and decide on it together. A joint committee accepts the requirements, and regular technical meetings align architecture decisions. Engine drivers of all partners test the DAS-Client during development.                                     |
| SBB IT                                                                     | Contracted by the cooperation partners to build and operate the DAS applications. Runs development and operations as one team: releases, monitoring, incident handling and the backlog. Acts as contact for the support staff of the partners.                |
| Railway undertakings (RU) using DAS                                        | Each RU manages the tablets (MDM), distributes and installs the DAS-Client app, manages user accounts in the identity provider, trains its engine drivers and communicates with them directly. An operations agreement defines support and service levels. |
| Infrastructure manager (IM), in Switzerland TMS-VAD as IM DAS-TS           | Provides train journeys and other operational data over SFERA. DAS displays this data and does not change its meaning. The IM stays responsible for the content.                                                                                            |

## Users

| Users                    | Who and what                                                                                                                                                         |
|:-------------------------|:---------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Engine drivers           | Engine drivers on duty use the DAS-Client on the tablet in the cab. They view the train journey and the information needed to run the train.                       |
| Observers                | People who do not drive, for example dispatch or accompanying staff, use the DAS-Client to view journey information. They do not get the driving functions.         |
| Tenant administrators    | They use the DAS-Admin-Tool to manage the data of their own tenant, for example feature toggles, indications, special holidays and external links.                  |
| General administrators   | Technical administrators at the operator of DAS. They use the DAS-Admin-Tool for settings across all tenants, for example companies and app versions.              |

The DAS-Client displays the same data whether or not the engine driver actively drives the train. Some features only trigger on the tablet on board the train, for example the WarnApp warning for a closed signal.
