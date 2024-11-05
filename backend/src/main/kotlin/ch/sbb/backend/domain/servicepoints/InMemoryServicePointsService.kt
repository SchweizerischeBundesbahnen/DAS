package ch.sbb.backend.domain.servicepoints

import ch.sbb.backend.application.rest.ServicePointDto
import org.springframework.stereotype.Service

@Service
class InMemoryServicePointsService {
    private val servicePoints = HashMap<Int, ServicePoint>()

    fun update(servicePoints: List<ServicePointDto>) {
        servicePoints.forEach {
            this.servicePoints[it.uic] = ServicePoint(it.uic, it.designation, it.abbreviation)
        }
    }

    fun getAll(): List<ServicePointDto> {
        return servicePoints.map {
            ServicePointDto(
                it.key,
                it.value.designation,
                it.value.abbreviation
            )
        }
    }

    fun getByUic(uic: Int): ServicePointDto? {
        return servicePoints[uic]?.let {
            ServicePointDto(it.uic, it.designation, it.abbreviation)
        }
    }
}


