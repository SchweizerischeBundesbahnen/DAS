package ch.sbb.das.backend.locations.internal;

import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@Configuration
@EnableJpaRepositories(basePackageClasses = {TafTapLocationRepository.class})
public class TafTapLocationPostgreSQLConfiguration {

}
