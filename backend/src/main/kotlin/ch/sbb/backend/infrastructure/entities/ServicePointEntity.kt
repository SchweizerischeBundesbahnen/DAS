package ch.sbb.backend.infrastructure.entities

import jakarta.persistence.Entity
import jakarta.persistence.Id

@Entity(name = "service_points")
 class ServicePointEntity(
    @Id
    var uic: Int,
    var designation: String,
    var abbreviation: String
)
