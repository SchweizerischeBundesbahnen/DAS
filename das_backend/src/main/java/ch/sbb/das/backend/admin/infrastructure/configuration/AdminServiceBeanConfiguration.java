package ch.sbb.das.backend.admin.infrastructure.configuration;

import ch.sbb.das.backend.admin.domain.links.ExternalLinkRepository;
import ch.sbb.das.backend.admin.domain.links.ExternalLinkService;
import ch.sbb.das.backend.admin.domain.links.ExternalLinkServiceImpl;
import ch.sbb.das.backend.admin.domain.ruindications.RuIndicationMatchService;
import ch.sbb.das.backend.admin.domain.ruindications.RuIndicationMatchServiceImpl;
import ch.sbb.das.backend.admin.domain.ruindications.RuIndicationRepository;
import ch.sbb.das.backend.admin.domain.ruindications.RuIndicationService;
import ch.sbb.das.backend.admin.domain.ruindications.RuIndicationServiceImpl;
import ch.sbb.das.backend.admin.domain.ruindications.RuIndicationTemplateRepository;
import ch.sbb.das.backend.admin.domain.ruindications.RuIndicationTemplateService;
import ch.sbb.das.backend.admin.domain.ruindications.RuIndicationTemplateServiceImpl;
import ch.sbb.das.backend.admin.domain.ruindications.SpecialHolidayRepository;
import ch.sbb.das.backend.admin.domain.ruindications.SpecialHolidayService;
import ch.sbb.das.backend.admin.domain.ruindications.SpecialHolidayServiceImpl;
import ch.sbb.das.backend.admin.domain.settings.AppVersionRepository;
import ch.sbb.das.backend.admin.domain.settings.AppVersionService;
import ch.sbb.das.backend.admin.domain.settings.AppVersionServiceImpl;
import ch.sbb.das.backend.admin.domain.settings.RuFeatureRepository;
import ch.sbb.das.backend.admin.domain.settings.RuFeatureService;
import ch.sbb.das.backend.admin.domain.settings.RuFeatureServiceImpl;
import ch.sbb.das.backend.tenancy.infrastructure.CompanyAuthorizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class AdminServiceBeanConfiguration {

    @Bean
    RuFeatureService ruFeatureService(RuFeatureRepository ruFeatureRepository) {
        return new RuFeatureServiceImpl(ruFeatureRepository);
    }

    @Bean
    AppVersionService appVersionService(AppVersionRepository appVersionRepository) {
        return new AppVersionServiceImpl(appVersionRepository);
    }

    @Bean
    RuIndicationTemplateService ruIndicationTemplateService(RuIndicationTemplateRepository ruIndicationTemplateRepository, CompanyAuthorizer companyAuthorizer) {
        return new RuIndicationTemplateServiceImpl(ruIndicationTemplateRepository, companyAuthorizer);
    }

    @Bean
    SpecialHolidayService specialHolidayService(SpecialHolidayRepository specialHolidayRepository, CompanyAuthorizer companyAuthorizer) {
        return new SpecialHolidayServiceImpl(specialHolidayRepository, companyAuthorizer);
    }

    @Bean
    RuIndicationService ruIndicationService(RuIndicationRepository ruIndicationRepository, CompanyAuthorizer companyAuthorizer) {
        return new RuIndicationServiceImpl(ruIndicationRepository, companyAuthorizer);
    }

    @Bean
    RuIndicationMatchService ruIndicationMatchService(RuIndicationRepository ruIndicationRepository, SpecialHolidayRepository specialHolidayRepository) {
        return new RuIndicationMatchServiceImpl(ruIndicationRepository, specialHolidayRepository);
    }

    @Bean
    ExternalLinkService externalLinkService(ExternalLinkRepository externalLinkRepository, CompanyAuthorizer companyAuthorizer) {
        return new ExternalLinkServiceImpl(externalLinkRepository, companyAuthorizer);
    }
}
