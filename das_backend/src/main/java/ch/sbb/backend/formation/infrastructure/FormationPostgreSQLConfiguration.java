package ch.sbb.backend.formation.infrastructure;

import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@Configuration
@EnableJpaRepositories(basePackageClasses = {TrainFormationRunRepository.class})
public class FormationPostgreSQLConfiguration {

}
