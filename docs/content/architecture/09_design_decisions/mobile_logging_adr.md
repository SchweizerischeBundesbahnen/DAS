---
title: Mobile Logging
draft: true
status: DECIDED
result: Delivery via backend
owner: Thomas Bomatter, Marco Ghilardelli
date: 2024-09-23
issue: 209
tags:
  - adr
---

{{< adr-table "adr" >}}

## Problem Background
A comprehensive logging concept is required so that DAS can act efficiently in the event of an error or support case and to ensure continuous monitoring of the systems. This concept should ensure that all relevant data can be recorded, stored and analysed. As a result, errors can be recognised and rectified at an early stage and events can be fully traced.

## Influences on the Decision
Splunk is in use at SBB.

## Assumptions
None.

## Considered Alternatives
None.

## Decisions
Delivery via backend.