---
title: 1.1 Requirements Overview
draft: true
cascade:
  type: docs
---

DRAFT

## What is the Driver Advisory System (DAS)?

DAS shows engine drivers the timetable and driving information for their train on a tablet. It
does not replace the driver machine interface (DMI) or line-side signals.

DAS implements the SFERA
standard [UIC IRS 90940:Ed3](https://uic.org/com/enews/article/3rd-edition-of-the-sfera-protocol-available-now-including-all-on-board-devices).
Railway undertakings (RU) can use it on networks where the infrastructure manager (IM) provides
journey data through SFERA. In Switzerland, the IM system is TMS-VAD. TMS-VAD computes the driving
advice, and DAS displays it unchanged.

## Name

Driver Advisory System is the term that UIC IRS 90940 uses. SFERA divides a DAS into an on-board
part, DAS-OB, and a trackside part, DAS-TS. This project builds the on-board part for railway
undertakings.

## Functional requirements

The DAS client shows the journey for a train number and date. This includes operational points,
speeds per train and brake series, slow zones, curves, level crossings, radio channels, notes and
the brake sheet. The client shows the current position, punctuality and the driving advice from
TMS-VAD. It warns the driver before a closed signal.

The DAS client exchanges journey profiles, segment profiles and train characteristics with TMS-VAD
over SFERA on MQTT. The DAS backend preloads segment profiles and train characteristics, so the
client can open journeys on a weak connection.

Users log in with their company account. Each user has one of four roles: driver, observer, admin
or RU admin. RU admins use the DAS admin tool to manage RU-specific notes, links, features and
supported app versions.

If DAS fails, drivers use a PDF timetable that the DAS backend generates in advance from NeTS,
eRADN and atlas data. For driver training, the DAS client runs against the simulator, with the
SFERA mock in place of TMS-VAD.

## Next

Dive right into the following section to get started:

{{< cards >}}
{{< card link="01_introduction" title="Context 1" icon="document-text" subtitle="Start with ..." >}}
{{< /cards >}}

{{< list-files dir="public/usecases" regexp=".pdf$" >}}
