---
title: Monorepo
draft: true
status: DECIDED
result: Monorepo
date: 2024-03-07
issue:
tags:
  - adr
---

{{< adr-table "adr" >}}

## Problem Background

Managing multiple repositories for the backend, web, and mobile applications presents challenges.
Each project operates in isolation, complicating coordination of changes across modules and leading
to versioning inconsistencies, duplicated documentation, and complex CI/CD processes.

## Basic conditions

- The ability to make changes that affect multiple projects in a single commit
  enhances clarity and tracking of related changes.
- Maintaining documentation in one location reduces the risk of
  inconsistencies and the need for duplication across different projects.
- The analysis of GitHub Actions revealed that it provides excellent support for
  CI/CD processes in a monorepo setup.
- With all projects housed in a single repository, we can apply versioning
  strategies uniformly, minimizing the risk of incompatibility among dependent projects.

## Assumptions

- The development team is familiar with Git and can effectively manage a monorepo.
- All stakeholders are aligned on the need for collaborative workflows and centralized resources.
- The tooling used (e.g., GitHub Actions) will continue to evolve to support monorepo practices
  effectively.

## Alternatives

### Multiple Repositories

Keeping separate repositories for each project/module.

#### Pros

Clear separation of concerns, easier to manage access control.

#### Cons

Increased overhead in managing dependencies, potential for versioning conflicts, and scattered
documentation.

## Decision

We have decided to implement a monorepo strategy for the backend, web, and mobile applications
within a single GitHub repository. This structure will facilitate atomic commits, centralized
documentation, streamlined CI/CD processes, and consistent versioning practices across all projects.
The decision is aimed at improving collaboration, reducing complexity, and enhancing the overall
development workflow.