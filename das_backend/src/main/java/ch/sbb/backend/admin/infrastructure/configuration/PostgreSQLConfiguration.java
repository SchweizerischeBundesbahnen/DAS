package ch.sbb.backend.admin.infrastructure.configuration;

import ch.sbb.backend.admin.infrastructure.servicepoint.SpringDataJpaServicePointRepository;
import ch.sbb.backend.admin.infrastructure.settings.SpringDataJpaRuFeatureRepository;
import ch.sbb.backend.common.AuditorAwareImpl;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.domain.AuditorAware;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@Configuration
@EnableJpaAuditing(auditorAwareRef = "auditorProvider")
@EnableJpaRepositories(basePackageClasses = {SpringDataJpaServicePointRepository.class, SpringDataJpaRuFeatureRepository.class})
public class PostgreSQLConfiguration {

    @Bean
    AuditorAware<String> auditorProvider() {
        return new AuditorAwareImpl();
    }
}
