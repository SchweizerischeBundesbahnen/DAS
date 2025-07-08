package ch.sbb.backend.formation.infrastructure.configuration;

import ch.sbb.backend.admin.domain.settings.CompanyService;
import ch.sbb.backend.formation.domain.TrainFormationRunRepository;
import ch.sbb.backend.formation.domain.TrainFormationService;
import ch.sbb.backend.formation.domain.TrainFormationServiceImpl;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class FormationServiceBeanConfiguration {

    @Bean
    TrainFormationService trainFormationService(TrainFormationRunRepository trainFormationRunRepository,
        CompanyService companyService) {
        return new TrainFormationServiceImpl(trainFormationRunRepository, companyService);
    }
}
