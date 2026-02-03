# Problem-Handling

**Error-handling** description of _Driver Advisory System_.

## DAS-Backend

### REST-APIs

Return a **[
`Problem`](https://developer-int.sbb.ch/accounts/868674d6-73c2-4a0b-a263-0a243c0d5723/applications/92180/documentation/11627)
object in a failure case with further description**, according
to [RFC 9457](https://datatracker.ietf.org/doc/html/rfc9457)
and [Restful API guidelines of Zalando about HTTP Status](https://opensource.zalando.com/restful-api-guidelines/#150).

Header values:

* `Content-Type` is set to `application/problem+json`.
* `Content-Language` is in most cases set to the one requested in `Accept-Language`.
* `Request-ID` is set to the one requested. It can help you diagnose problems by correlating
  traceability and/or log entries for a given web request across many systems and log files.

Example:

    HTTP/1.1 400 Bad Request
    content-type: application/problem+json
    content-language: de
    request-id: testing the documentation
    
    {
     "status": 400
     "type": "<link to this page>",
     "title": "Bad value for parameter: company",
     "detail": "Use proper RICS code or supported RU.",
     "instance": "/v1/formations/7762/2026-01-22/1033"
    }

## DAS-Client

## DAS-Admin-Tool
