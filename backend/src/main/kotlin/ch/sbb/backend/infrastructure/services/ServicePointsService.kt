package ch.sbb.backend.infrastructure.services

import ch.sbb.backend.application.rest.ServicePointDto
import ch.sbb.backend.infrastructure.repositories.ServicePointsRepository
import org.springframework.stereotype.Service

@Service
class ServicePointsService(private val servicePointsRepository: ServicePointsRepository) {
    fun getByUic(uic: Int): ServicePointDto? {
        return servicePointsRepository.getByUic(uic)
    }

    fun update(servicePoints: List<ServicePointDto>) {
        return servicePointsRepository.update(servicePoints)
    }

    fun getAll(): List<ServicePointDto> {
        return servicePointsRepository.getAll()
    }
}
