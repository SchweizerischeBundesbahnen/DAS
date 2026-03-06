package ch.sbb.backend.admin.domain.settings;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class AppVersionConfig {

    @Bean
    public AppVersionService appVersionService(AppVersionRepository appVersionRepository) {
        return new AppVersionServiceImpl(appVersionRepository);
    }
}


