package ch.sbb.backend.domain.servicepoints

import ch.sbb.backend.application.rest.ServicePointRequest
import ch.sbb.backend.application.rest.ServicePointResponse
import org.springframework.stereotype.Service

@Service
class InMemoryServicePointsService {
    private val servicePoints = HashMap<Int, ServicePoint>()

    fun update(servicePoints: List<ServicePointRequest>) {
        servicePoints.forEach {
            this.servicePoints[it.uic] = ServicePoint(it.uic, it.designation, it.abbreviation)
        }
    }

    fun getAll(): List<ServicePointResponse> {
        return servicePoints.map {
            ServicePointResponse(
                it.key,
                it.value.designation,
                it.value.abbreviation
            )
        }
    }

    fun getByUic(uic: Int): ServicePointResponse? {
        return servicePoints[uic]?.let {
            ServicePointResponse(it.uic, it.designation, it.abbreviation)
        }
    }
}


