package ch.sbb.das.backend.admin.infrastructure.configuration;

import ch.sbb.das.backend.admin.domain.notices.NoticeMatchService;
import ch.sbb.das.backend.admin.domain.notices.NoticeMatchServiceImpl;
import ch.sbb.das.backend.admin.domain.notices.NoticeRepository;
import ch.sbb.das.backend.admin.domain.notices.NoticeService;
import ch.sbb.das.backend.admin.domain.notices.NoticeServiceImpl;
import ch.sbb.das.backend.admin.domain.notices.NoticeTemplateRepository;
import ch.sbb.das.backend.admin.domain.notices.NoticeTemplateService;
import ch.sbb.das.backend.admin.domain.notices.NoticeTemplateServiceImpl;
import ch.sbb.das.backend.admin.domain.notices.SpecialHolidayRepository;
import ch.sbb.das.backend.admin.domain.notices.SpecialHolidayService;
import ch.sbb.das.backend.admin.domain.notices.SpecialHolidayServiceImpl;
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
    NoticeTemplateService noticeTemplateService(NoticeTemplateRepository noticeTemplateRepository) {
        return new NoticeTemplateServiceImpl(noticeTemplateRepository);
    }

    @Bean
    SpecialHolidayService specialHolidayService(SpecialHolidayRepository specialHolidayRepository, CompanyAuthorizer companyAuthorizer) {
        return new SpecialHolidayServiceImpl(specialHolidayRepository, companyAuthorizer);
    }

    @Bean
    NoticeService noticeService(NoticeRepository noticeRepository, CompanyAuthorizer companyAuthorizer) {
        return new NoticeServiceImpl(noticeRepository, companyAuthorizer);
    }

    @Bean
    NoticeMatchService noticeMatchService(NoticeRepository noticeRepository, SpecialHolidayRepository specialHolidayRepository) {
        return new NoticeMatchServiceImpl(noticeRepository, specialHolidayRepository);
    }
}
