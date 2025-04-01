package ch.sbb.backend.logging.infrastructure.config;

import ch.sbb.backend.logging.domain.repository.LoggingRepository;
import ch.sbb.backend.logging.domain.repository.TenantRepository;
import ch.sbb.backend.logging.domain.service.DomainLoggingService;
import ch.sbb.backend.logging.domain.service.DomainTenantService;
import ch.sbb.backend.logging.domain.service.LoggingService;
import ch.sbb.backend.logging.domain.service.TenantService;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class LoggingBeanConfiguration {

    @Bean
    LoggingService logService(LoggingRepository loggingRepository) {
        return new DomainLoggingService(loggingRepository);
    }

    @Bean
    TenantService tenantService(TenantRepository tenantRepository) {
        return new DomainTenantService(tenantRepository);
    }
}
