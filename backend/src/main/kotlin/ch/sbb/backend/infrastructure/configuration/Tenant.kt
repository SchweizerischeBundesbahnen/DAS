package ch.sbb.backend.infrastructure.configuration

data class Tenant(
    var name: String? = null,
    var id: String? = null,
    var jwkSetUri: String? = null,
    var issuerUri: String? = null,
    var logDestination: LogDestination? = null
)
