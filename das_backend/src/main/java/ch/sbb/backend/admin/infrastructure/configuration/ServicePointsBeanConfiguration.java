package ch.sbb.backend.admin.infrastructure.configuration;

import ch.sbb.backend.admin.domain.repository.ServicePointRepository;
import ch.sbb.backend.admin.domain.service.DomainServicePointService;
import ch.sbb.backend.admin.domain.service.ServicePointService;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class ServicePointsBeanConfiguration {

    @Bean
    ServicePointService servicePointService(ServicePointRepository servicePointRepository) {
        return new DomainServicePointService(servicePointRepository);
    }
}
