package ch.sbb.das.backend.preload.infrastructure.configuration;

import ch.sbb.das.backend.preload.infrastructure.TrainIdentificationRepository;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@Configuration
@EnableJpaRepositories(basePackageClasses = {TrainIdentificationRepository.class})
public class PreloadPostgreSQLConfiguration {

}
