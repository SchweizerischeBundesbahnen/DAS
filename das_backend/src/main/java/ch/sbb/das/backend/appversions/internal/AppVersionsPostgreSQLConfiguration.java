package ch.sbb.das.backend.appversions.internal;

import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@Configuration
@EnableJpaRepositories(basePackageClasses = {AppVersionRepository.class})
public class AppVersionsPostgreSQLConfiguration {

}
