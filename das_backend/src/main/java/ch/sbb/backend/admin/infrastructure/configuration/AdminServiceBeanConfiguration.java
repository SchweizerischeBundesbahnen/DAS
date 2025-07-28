package ch.sbb.backend.admin.infrastructure.configuration;

import ch.sbb.backend.admin.domain.servicepoint.ServicePointRepository;
import ch.sbb.backend.admin.domain.servicepoint.ServicePointService;
import ch.sbb.backend.admin.domain.servicepoint.ServicePointServiceImpl;
import ch.sbb.backend.admin.domain.settings.CompanyRepository;
import ch.sbb.backend.admin.domain.settings.CompanyService;
import ch.sbb.backend.admin.domain.settings.CompanyServiceImpl;
import ch.sbb.backend.admin.domain.settings.RuFeatureRepository;
import ch.sbb.backend.admin.domain.settings.RuFeatureService;
import ch.sbb.backend.admin.domain.settings.RuFeatureServiceImpl;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class AdminServiceBeanConfiguration {

    @Bean
    ServicePointService servicePointService(ServicePointRepository servicePointRepository) {
        return new ServicePointServiceImpl(servicePointRepository);
    }

    @Bean
    RuFeatureService ruFeatureService(RuFeatureRepository ruFeatureRepository) {
        return new RuFeatureServiceImpl(ruFeatureRepository);
    }

    @Bean
    CompanyService companyService(CompanyRepository companyRepository) {
        return new CompanyServiceImpl(companyRepository);
    }
}
