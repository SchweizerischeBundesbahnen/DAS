package ch.sbb.backend.formation;

import ch.sbb.backend.formation.infrastructure.TrainFormationRunRepository;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@Configuration
@EnableJpaRepositories(basePackageClasses = {TrainFormationRunRepository.class})
public class FormationPostgreSQLConfiguration {

}
