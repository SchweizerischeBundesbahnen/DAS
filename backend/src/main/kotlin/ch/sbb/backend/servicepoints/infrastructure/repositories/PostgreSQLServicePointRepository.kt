package ch.sbb.backend.servicepoints.infrastructure.repositories

import ch.sbb.backend.servicepoints.domain.ServicePoint
import ch.sbb.backend.servicepoints.domain.repository.ServicePointRepository
import ch.sbb.backend.servicepoints.infrastructure.entities.ServicePointEntity
import org.springframework.stereotype.Component

@Component
class PostgreSQLServicePointRepository(private val servicePointRepository: SpringDataJpaServicePointRepository) :
    ServicePointRepository {
    override fun findByUic(uic: Int): ServicePoint? {
        return servicePointRepository.findByUic(uic)?.toServicePoint()
    }

    override fun findAll(): List<ServicePoint> {
        return servicePointRepository.findAll().map { it.toServicePoint() }
    }

    override fun saveAll(servicePoints: List<ServicePoint>) {
        servicePointRepository.saveAll(servicePoints.map { ServicePointEntity(it) })
    }

    override fun save(servicePoint: ServicePoint) {
        servicePointRepository.save(ServicePointEntity(servicePoint))
    }
}
