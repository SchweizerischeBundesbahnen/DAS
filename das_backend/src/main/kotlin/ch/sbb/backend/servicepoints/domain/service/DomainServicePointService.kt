package ch.sbb.backend.servicepoints.domain.service

import ch.sbb.backend.servicepoints.domain.ServicePoint
import ch.sbb.backend.servicepoints.domain.repository.ServicePointRepository

class DomainServicePointService(private val servicePointRepository: ServicePointRepository) :
    ServicePointService {
    override fun getAll(): List<ServicePoint> {
        return servicePointRepository.findAll()
    }

    override fun findByUic(uic: Int): ServicePoint? {
        return servicePointRepository.findByUic(uic)
    }

    override fun updateAll(servicePoints: List<ServicePoint>) {
        servicePointRepository.saveAll(servicePoints)
    }

    override fun create(servicePoint: ServicePoint) {
        servicePointRepository.save(servicePoint)
    }

}
