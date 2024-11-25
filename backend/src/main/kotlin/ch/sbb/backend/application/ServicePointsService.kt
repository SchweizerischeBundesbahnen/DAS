package ch.sbb.backend.application

import ch.sbb.backend.api.ServicePointDto
import ch.sbb.backend.domain.servicepoints.ServicePoint

interface ServicePointsService {

    fun findByUic(uic: Int): ServicePoint?

    fun update(servicePoints: List<ServicePointDto>): List<ServicePoint>

    fun getAll(): List<ServicePoint>
}
