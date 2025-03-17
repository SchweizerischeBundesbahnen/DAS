---
title: 6.2 Authorisation and Roles
draft: true
cascade:
  type: docs
---

Remarks:
* Every RU has its own Authentication (IAM) system and is therefore not controlled centrally.
* The RU Device-Management (MDM) system may depend on IAM roles (for e.g. App distribution per trusted user).

## Roles
For users using the DAS App.

### Driver
de: Lokpersonal

Train/engine driver with permission to perform a vehicle-journey, including staff in education.

### Observer
Any DAS App user without permission to perform a vehicle-journey (for e.g. de:Fahrdienstleiter (FDL)).

### RU Admin
Administrators at a Railway Undertaking (de:EVU) managing their users/roles for DAS by a Mobile Device Management (MDM) and Authentication system.

### Admin
DAS Administrator with global rights for DAS-Admin settings.

## DAS Role comparison to TMS::VAD Roles
Roles within DAS remain consistent over all vehicle-journeys. However, per train instance the currently active driver is needed additionally:

| Role DAS                                       | Role assigned to TMS::VAD        |
|------------------------------------------------|----------------------------------|
| `Driver` - active person on train nr: 1234     | active `Driver` on train nr: 1234|  
| `Driver` - NOT active person on train nr: 1234 | `Observer` on train nr: 1234     |  
| `Observer`                                     | `Observer` on train nr: 1234     |  

A `Driver` is also an `Observer`, therefore an explicite distinction for non-active `Driver` is not necessary.
