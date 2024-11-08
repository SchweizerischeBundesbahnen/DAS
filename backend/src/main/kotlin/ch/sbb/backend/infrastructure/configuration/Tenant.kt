package ch.sbb.backend.infrastructure.configuration

data class Tenant(
    var name: String,
    var id: String,
    var jwkSetUri: String,
    var issuerUri: String,
    var logDestination: LogDestination
)
