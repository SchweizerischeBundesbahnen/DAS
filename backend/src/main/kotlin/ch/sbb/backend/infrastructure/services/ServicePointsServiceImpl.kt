package ch.sbb.backend.infrastructure.services

import ch.sbb.backend.api.ServicePointDto
import ch.sbb.backend.application.ServicePointsService
import ch.sbb.backend.domain.servicepoints.ServicePoint
import ch.sbb.backend.infrastructure.entities.ServicePointEntity
import ch.sbb.backend.infrastructure.repositories.ServicePointsRepository
import org.springframework.stereotype.Service

@Service
class ServicePointsServiceImpl(private val servicePointsRepository: ServicePointsRepository) :
    ServicePointsService {
    override fun findByUic(uic: Int): ServicePoint? {
        return servicePointsRepository.findByUic(uic)?.mapToServicePoint()
    }

    override fun update(servicePoints: List<ServicePointDto>): List<ServicePoint> {
        return servicePointsRepository.saveAll(servicePoints.map { it.toEntity() })
            .map { it.mapToServicePoint() }
    }

    override fun getAll(): List<ServicePoint> {
        return servicePointsRepository.findAll().map { it.mapToServicePoint() }
    }

    fun ServicePointEntity.mapToServicePoint(): ServicePoint {
        return ServicePoint(uic, designation, abbreviation)
    }

    fun ServicePointDto.toEntity(): ServicePointEntity {
        return ServicePointEntity(uic, designation, abbreviation)
    }
}
