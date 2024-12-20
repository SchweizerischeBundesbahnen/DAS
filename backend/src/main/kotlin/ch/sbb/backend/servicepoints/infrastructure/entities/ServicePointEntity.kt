package ch.sbb.backend.servicepoints.infrastructure.entities

import ch.sbb.backend.servicepoints.domain.ServicePoint
import jakarta.persistence.Entity
import jakarta.persistence.Id

@Entity(name = "service_points")
class ServicePointEntity(
    @Id
    var uic: Int,
    var designation: String,
    var abbreviation: String
) {


    constructor(servicePoint: ServicePoint) : this(
        servicePoint.uic,
        servicePoint.designation,
        servicePoint.abbreviation
    )

    fun toServicePoint():ServicePoint {
       return ServicePoint(uic,designation, abbreviation)
    }
}
