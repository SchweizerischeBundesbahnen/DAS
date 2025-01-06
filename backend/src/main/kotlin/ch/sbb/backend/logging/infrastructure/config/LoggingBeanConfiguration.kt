package ch.sbb.backend.logging.infrastructure.config

import ch.sbb.backend.logging.domain.MultitenantLoggingService
import ch.sbb.backend.logging.domain.repository.TenantRepository
import ch.sbb.backend.logging.domain.service.DomainLoggingService
import ch.sbb.backend.logging.domain.service.DomainTenantService
import ch.sbb.backend.logging.domain.service.TenantService
import ch.sbb.backend.logging.infrastructure.ConsoleLoggingRepository
import ch.sbb.backend.logging.infrastructure.SplunkLoggingRepository
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
class LoggingBeanConfiguration {

    @Bean
    fun multitenantLoggingService(
        tenantService: TenantService,
        splunkLoggingRepository: SplunkLoggingRepository,
        consoleLoggingRepository: ConsoleLoggingRepository
    ): MultitenantLoggingService {
        return MultitenantLoggingService(tenantService, DomainLoggingService(splunkLoggingRepository), DomainLoggingService(consoleLoggingRepository))
    }

    @Bean
    fun teanantService(tenantRepository: TenantRepository): TenantService {
        return DomainTenantService(tenantRepository)
    }
}
