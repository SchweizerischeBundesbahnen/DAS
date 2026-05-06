package ch.sbb.das.backend.admin.infrastructure.configuration;

import ch.sbb.das.backend.admin.infrastructure.jpa.SpringDataJpaAppVersionRepository;
import ch.sbb.das.backend.admin.infrastructure.jpa.SpringDataJpaNoticeTemplateRepository;
import ch.sbb.das.backend.admin.infrastructure.jpa.SpringDataJpaRuFeatureRepository;
import ch.sbb.das.backend.admin.infrastructure.jpa.SpringDataJpaTafTapLocationRepository;
import ch.sbb.das.backend.common.AuditorAwareImpl;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.domain.AuditorAware;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@Configuration
@EnableJpaAuditing(auditorAwareRef = "auditorProvider")
@EnableJpaRepositories(basePackageClasses = {SpringDataJpaRuFeatureRepository.class, SpringDataJpaAppVersionRepository.class, SpringDataJpaTafTapLocationRepository.class,
    SpringDataJpaNoticeTemplateRepository.class})
public class AdminPostgreSQLConfiguration {

    @Bean
    AuditorAware<String> auditorProvider() {
        return new AuditorAwareImpl();
    }
}
