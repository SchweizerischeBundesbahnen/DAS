# mqtt – Agent Guide

## Purpose

MQTT client used for SFERA/TMS messaging with the backend. Wraps `mqtt_client` behind a `MqttService`, with pluggable
connectors for OAuth (Azure AD) and TMS OpenID authentication.

