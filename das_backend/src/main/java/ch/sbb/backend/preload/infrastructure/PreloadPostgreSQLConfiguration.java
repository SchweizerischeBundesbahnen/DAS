package ch.sbb.backend.preload.infrastructure;

import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@Configuration
@EnableJpaRepositories(basePackageClasses = {TrainRunRepository.class})
public class PreloadPostgreSQLConfiguration {

}
