---
title: 10.1 Utility Tree
cascade:
  type: docs
---
The priority quality objectives of DAS in order of importance.

![](utility_tree.svg)

Reliability - Railway operations depend on it.
: DAS is available during all railway operations. Failures of an external system do not prevent DAS from providing all available information.

-> Entkopplung (z.B. Logging), Azure down: keine Chance (spielt keine Rolle, wenn drin, bis Refresh failed), Daten vorladen, was passiert, wenn keine Netzwerkverbindung (Login offline möglich, Caching der Anmeldeinformationen), möglichst wenige Umsysteme / Abhängigkeiten
Offene Punkte: Authentifizierung / Token-Gültigkeit MQTT, wird Access Token nur initial benötigt? Macht hier TMS noch Konfiguration?

Functional Suitability - Provided information is correct.
: DAS only displays and never modifies data. A data source can rely on DAS to present the provided data completely and with the intentioned meaning.

-> Ausführliche Tests (end-to-end), Zwischensysteme vermeiden, View-Model read-only (final), Mapper, Testsuite, UI-Tests, v.a. für SFERA, 

Operability - Reliable and efficient operation.
: The system is efficient to operate and oversee. Problems can be identified and mitigated in a timely manner.

-> Logging, Monitoring (Splunk ?), Crash-Recorder, Dashboard, Tracing, keine unnötigen Dependencies,

Maintainability - Changes need to be implemented efficiently and safely.
: New functionality can be implemented in a predictive manner while guaranteeing to not break existing functionality. Additional railway undertakings can be easily integrated. 

-> keine unnötigen Dependencies (Check, ob Dependencies "gut" sind), APIM, Modularisierung (auch Projektstruktur), SBB Standards einsetzen, Lint enforced Modularisierung, Arch Unit (DDD),  

Usability - Support, not distract the engine driver
: Providing a simple and concise user interface for engine drivers to support operations and avoid distractions is paramount.

-> UX, Research, Testing, Einfluss/Zusammenarbeit im Entwicklungsprozess

### Further objectives which are relevant for OpenDAS in the context of Functional Suitability:

Auditability - Like an open book
: It is easy to check and understand the functionality, data flows and logic.

-> Logging, Open Source, comprehensive documentation, 

Safety - No influence on safety of operations
: The circumstances of the use of the systems are always respected. No unnecessary functionality or distracting features will be implemented. 

-> K 250, Prozesse SBB folgen, ISO miteinbeziehen, Testing, Simulatoren