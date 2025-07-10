package ch.sbb.backend.formation.infrastructure.configuration;

import ch.sbb.backend.formation.infrastructure.trainformation.JpaTrainFormationRunRepository;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@Configuration
@EnableJpaRepositories(basePackageClasses = {JpaTrainFormationRunRepository.class})
public class FormationPostgreSQLConfiguration {

}
