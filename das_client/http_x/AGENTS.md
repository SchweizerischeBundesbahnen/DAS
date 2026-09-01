# http_x – Agent Guide

Extends the `http` package with interceptors for bearer-token authorization, request/response logging (secrets
obfuscated), and `Accept-Language`; maps non-2xx responses to typed `HttpException` subclasses. Used by almost every
feature package that talks to a REST backend.

