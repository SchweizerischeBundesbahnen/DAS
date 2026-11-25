---
title: Downstream Resilience
draft: true
status: DECIDED
result: Timeouts and retries, no circuit breaker, no bulkhead
date: 2026-11-25
issue: 2652
tags:
  - adr
---

{{< adr-table "adr" >}}

## Problem Background

DAS-Backend calls GEMS, ORCA, atlas and the Entra ID token endpoint synchronously. Until now none of these calls had a connect or read timeout. A downstream
service that hangs kept a backend request thread waiting until the TCP connection died. APIM answers the caller after 30 s, but the backend thread kept
waiting. A timeout or a refused connection reached the caller as a generic 500, and one failed atlas page aborted the nightly location import.

## Basic conditions

* GEMS and ORCA are called while a user waits. APIM in front of the backend cuts a request after 30 s.
* atlas is called once a night by the location import, which pages through about 2000 service points per request.
* The Entra ID token call happens inside the GEMS, ORCA and atlas calls when the cached token has expired, and before the MQTT connect to SFERA.
* The call volume is low: a few requests per minute per downstream service.
* Spring Boot uses Apache HttpClient 5 for the REST clients, because Spring Cloud Vault puts it on the classpath.

## Assumptions

* GEMS accepts a repeated subscribe or confirm. DAS-Client already resends a subscription with the same messageId until it is confirmed.
* With a read timeout of 10 s, the 200 Tomcat threads fill up only at about 20 requests per second to a downstream service that is down.

## Alternatives

1. Resilience4j with retry, circuit breaker and bulkhead. It adds a dependency and its configuration, for a call volume where a circuit breaker opens late
   and protects little.
2. The `@Retryable` annotation of Spring Framework 7. It retries without a new dependency, but gives no hook that knows the attempt number, which the log
   needs.
3. `RetryTemplate` of Spring Framework 7 with a `RetryListener`, the same retry engine as `@Retryable`.
4. Timeouts only, and no retry.

## Decision

Alternative 3, together with timeouts on every downstream call.

* Every downstream service has a connect and a read timeout: 5 s and 10 s, and 60 s read timeout for an atlas page. The default comes from
  `spring.http.clients`, `downstream.*` in `application.yaml` sets the value per downstream service.
* `DownstreamCalls` retries connection failures, connect timeouts and the status codes 502, 503 and 504. It never retries a 4xx or a 500.
* A call a user waits on is retried twice, after 500 ms and 1 s. It does not retry a read timeout, because the downstream may have processed the request and
  a second read timeout would exceed the 30 s of APIM. The worst case is three connect timeouts plus the backoff, about 16.5 s.
* An atlas page is retried three times, after 2 s, 4 s and 8 s, also after a read timeout.
* The built-in retries of Apache HttpClient are disabled, so `DownstreamCalls` is the only place that retries.
* Each failed attempt is logged once at WARN with the downstream name, the operation, the attempt number, the duration and the reason.
* After the last attempt a timeout becomes a 504 and a connection failure or a failed token call a 502, both as `Problem` with the title
  "Downstream Service Error".

There is no circuit breaker and no bulkhead. The timeouts release the threads, the volume is low and APIM limits what reaches the backend.

We reconsider a circuit breaker or a bulkhead when one of these happens:

* Instana shows Tomcat thread saturation during an outage of a downstream service.
* A downstream service receives more than about 5 requests per second.

Who:

- Nico Vidoni
