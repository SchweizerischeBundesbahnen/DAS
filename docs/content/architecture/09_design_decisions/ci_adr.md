---
title: CI
draft: true
status: DECIDED
result: GitHub Actions
date: 2024-03-07
issue: 
tags:
  - adr
---

{{< adr-table "adr" >}}

## Problem Background
CI is essential for our development process.

## Basic conditions
The decision is influenced by SBB's established use of GitHub for its Open Source projects, which provides a familiar environment for our development teams.

## Assumptions
None.

## Alternatives
None.

## Decision
### GitHub Actions
We have decided to implement CI using GitHub Actions wherever feasible.

#### Reason
* GitHub Actions are natively integrated with the GitHub platform, allowing for streamlined workflows directly alongside the source code.
* GitHub Actions benefits greatly from an extensive ecosystem and active community support. This leads to a large number of available actions that can be used for different purposes
