package ch.sbb.backend.servicepoints.domain.service

import ch.sbb.backend.servicepoints.domain.ServicePoint

interface ServicePointService {
    fun getAll(): List<ServicePoint>
    fun findByUic(uic: Int): ServicePoint?
    fun updateAll(servicePoints: List<ServicePoint>)
    fun create(servicePoint: ServicePoint)
}
