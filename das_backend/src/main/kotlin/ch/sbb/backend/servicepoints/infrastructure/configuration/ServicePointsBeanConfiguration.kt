package ch.sbb.backend.servicepoints.infrastructure.configuration

import ch.sbb.backend.servicepoints.domain.service.DomainServicePointService
import ch.sbb.backend.servicepoints.domain.repository.ServicePointRepository
import ch.sbb.backend.servicepoints.domain.service.ServicePointService
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
class ServicePointsBeanConfiguration {

    @Bean
    fun servicePointService(servicePointRepository: ServicePointRepository): ServicePointService {
        return DomainServicePointService(servicePointRepository)
    }

}
