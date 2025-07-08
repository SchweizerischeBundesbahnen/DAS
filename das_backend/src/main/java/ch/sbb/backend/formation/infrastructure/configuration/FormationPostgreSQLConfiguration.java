package ch.sbb.backend.formation.infrastructure.configuration;

import ch.sbb.backend.formation.infrastructure.trainformation.SpringDataJpaTrainFormationRunRepository;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@Configuration
@EnableJpaRepositories(basePackageClasses = {SpringDataJpaTrainFormationRunRepository.class})
public class FormationPostgreSQLConfiguration {

}
