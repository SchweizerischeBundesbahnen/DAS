---
title: Authentication
draft: true
status: DECIDED
result: Multi Tenant Entra ID (Azure AD)
date: 2024-03-07
issue: 
tags:
  - adr
---

{{< adr-table "adr" >}}

{{< callout type="error" >}}
Check again, how are smaller RUs supported? How does the detailed solution look like? Any changes since July? Needs work!
{{< /callout >}}

## Problem Background
DAS is operated for various RUs and must therefore have an exchangeable or broadly supported authorisation or identity concept.

## Basic conditions
* Microsoft Identity Platform Entra (aka `Entity ID`, `Azure AD`) is the standard technology for IAM in all the participating organizations.
* In order to authenticate other companies/EVUs, a federation of `Entity IDs` must be created.
* With **Multi-tenant**, the participating organizations must manage the identities and can therefore be delegated.
* With Crosstenant, all identities would have to be managed by one company. However, the one company does not know the identities and cannot know which identities should have which access.
* If there is no identity federation, each RU would have to operate a DAS itself, which is not currently planned.
* Other multi organization projects on swiss railway have already Azure Multinancy in place


## Assumptions
* [Authorization code flow (with OAuth2)](https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-auth-code-flow) for User Logins is sufficient for trusted Mobile- and Web-App authentication
* [Client credentials flow (with OAuth2)](https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-client-creds-grant-flow) for machine-to-machine authentication is sufficient

## Alternatives
* Crosstenant

## Decision
Because all cooperation partners use `Entity ID`, the authentication and role management of DAS is implemented with `Entity ID` (multi-tenant).