package ch.sbb.das.backend.externallinks.internal;

import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@Configuration
@EnableJpaRepositories(basePackageClasses = {ExternalLinkRepository.class})
public class ExternalLinksPostgreSQLConfiguration {

}
