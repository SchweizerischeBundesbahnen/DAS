package ch.sbb.backend.logging.domain

data class Tenant(
    var name: String,
    var id: String,
    var jwkSetUri: String,
    var issuerUri: String,
    var logDestination: LogDestination
)
