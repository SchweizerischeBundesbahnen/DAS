package ch.sbb.das.backend.admin.infrastructure.configuration;

import ch.sbb.das.backend.admin.domain.notices.NoticeTemplateRepository;
import ch.sbb.das.backend.admin.domain.notices.NoticeTemplateService;
import ch.sbb.das.backend.admin.domain.notices.NoticeTemplateServiceImpl;
import ch.sbb.das.backend.admin.domain.settings.AppVersionRepository;
import ch.sbb.das.backend.admin.domain.settings.AppVersionService;
import ch.sbb.das.backend.admin.domain.settings.AppVersionServiceImpl;
import ch.sbb.das.backend.admin.domain.settings.RuFeatureRepository;
import ch.sbb.das.backend.admin.domain.settings.RuFeatureService;
import ch.sbb.das.backend.admin.domain.settings.RuFeatureServiceImpl;
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
}
