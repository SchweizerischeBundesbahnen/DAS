---
title: CI/CD process
draft: true
status: DECIDED
result: Monorepo and GitHub Actions
owner: Thomas Bomatter, Marco Ghilardelli
date: 2024-03-07
issue: 
tags:
  - adr
---

{{< adr-table "adr" >}}

## Problem Background
CI/CD is needed.

## Influences on the Decision
SBB uses GitHub for Open Source projects.

## Assumptions
None.

## Considered Alternatives
None.

## Decisions
### Monorepo
DAS is provided in a monorepo on GitHub. This means that the backend, web and mobile application are available as subfolders in the same repository.
#### Reason
* **Atomic commits:** Changes that affect multiple projects/modules can be made in a single commit, which makes it easier to keep track of related changes.
* **Documentation:** The documentation can be provided in a central location for all participating modules and does not have to be duplicated and maintained in several locations for cross-component topics.
* **Tooling:** The analysed tool (GitHub Actions) offers out of the box support, which enables CI/CD tasks with Monorepos well.
* **Consistent version management:** As all projects are in the same repository, versioning strategies can be applied consistently and the risk of incompatibilities between dependent projects can be reduced.
### GitHub Actions
CI/CD is implemented as far as possible with GitHub Actions.
#### Reason
* Actions are on GitHub, where the code is also located, and therefore optimal integration is possible
* GitHub Actions benefits greatly from an extensive ecosystem and active community support. This leads to a large number of available actions that can be used for different purposes
#### Mobile app
The mobile app can be automated with actions up to and including store deployment.
#### Backend/Web
Backend and web are provided with actions as (Docker) images. Deployment to the cloud is implemented internally with ArgoCD. It is built with public Docker base images (not SBB-specific). The only known limitation is the NewRelic integration. (New Relic is not expected to be used)