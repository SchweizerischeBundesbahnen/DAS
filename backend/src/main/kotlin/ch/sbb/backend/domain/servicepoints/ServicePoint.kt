package ch.sbb.backend.domain.servicepoints

import ch.sbb.backend.api.ServicePointDto

data class ServicePoint(
    val uic: Int,
    val designation: String,
    val abbreviation: String
) {
    fun toApi(): ServicePointDto {
        return ServicePointDto(uic, designation, abbreviation)
    }

    companion object {
        fun toApi(servicePoints: List<ServicePoint>): List<ServicePointDto> {
            return servicePoints.map { it.toApi() }
        }
    }
}
