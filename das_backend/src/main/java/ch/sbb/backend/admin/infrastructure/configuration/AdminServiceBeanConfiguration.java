package ch.sbb.backend.admin.infrastructure.configuration;

import ch.sbb.backend.admin.domain.settings.AppVersionRepository;
import ch.sbb.backend.admin.domain.settings.AppVersionService;
import ch.sbb.backend.admin.domain.settings.AppVersionServiceImpl;
import ch.sbb.backend.admin.domain.settings.RuFeatureRepository;
import ch.sbb.backend.admin.domain.settings.RuFeatureService;
import ch.sbb.backend.admin.domain.settings.RuFeatureServiceImpl;
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
}
