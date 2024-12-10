package ch.sbb.backend.servicepoints.infrastructure.configuration

import ch.sbb.backend.servicepoints.domain.repository.DomainServicePointService
import ch.sbb.backend.servicepoints.domain.repository.ServicePointRepository
import ch.sbb.backend.servicepoints.domain.service.ServicePointService
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
class BeanConfiguration {

    @Bean
    fun orderService(servicePointRepository: ServicePointRepository): ServicePointService {
        return DomainServicePointService(servicePointRepository)
    }

}
