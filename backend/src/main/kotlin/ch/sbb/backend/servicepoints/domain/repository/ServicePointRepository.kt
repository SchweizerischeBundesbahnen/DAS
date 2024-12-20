package ch.sbb.backend.servicepoints.domain.repository

import ch.sbb.backend.servicepoints.domain.ServicePoint

interface ServicePointRepository {
    fun findByUic(uic: Int): ServicePoint?
    fun findAll(): List<ServicePoint>
    fun saveAll(servicePoints: List<ServicePoint>)
    fun save(servicePoint: ServicePoint)
}
