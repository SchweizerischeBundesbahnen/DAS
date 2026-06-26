package ch.sbb.das.backend.indications.internal;

import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@Configuration
@EnableJpaRepositories(basePackageClasses = {
    RuIndicationTemplateRepository.class,
    RuIndicationRepository.class})
public class RuIndicationPostgreSQLConfiguration {

}
