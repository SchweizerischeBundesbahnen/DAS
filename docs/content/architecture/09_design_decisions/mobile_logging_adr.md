---
title: Mobile Logging
draft: true
status: DECIDED
result: Delivery via backend
date: 2025-06-04
issue: 209, 522
tags:
  - adr
---

{{< adr-table "adr" >}}

## Problem Background

A comprehensive logging concept is required so that DAS operators can act efficiently in the event of an error
or support case and to ensure continuous monitoring/alerting of the systems. This concept should ensure that
all relevant data can be recorded, stored and analysed. As a result, errors can be recognised and
rectified at an early stage and events can be fully traced.

## Basic conditions

* We can separate (at least filter/index) different logs for each tenant (respectively RUs).
* There are libraries to be used by DAS-Client (mobile App in the context of Flutter) or by DAS-Backend (Java SLF4J).

## Assumptions

Direct logging by each component directly to the logging-instance allows for maximal resilience (logging might be key).  
One logging-product is enough (for e.g. SBB prefers Splunk).  
One logging-instance is enough. If anytime later RUs prefer their own instances, an easy mechanism for multiplexing can be introduced (URL/secrets per RU).

## Alternatives

1. DAS-Client could log to DAS-Backend by an intermediate layer to more comfortably delegate tenant technology and/or instances.

## Decision

Each DAS component writes separately into the same logging-instance (by "tag" for RU and component).