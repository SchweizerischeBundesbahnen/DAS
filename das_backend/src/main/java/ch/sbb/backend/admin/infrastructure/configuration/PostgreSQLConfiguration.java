package ch.sbb.backend.admin.infrastructure.configuration;

import ch.sbb.backend.admin.infrastructure.repositories.SpringDataJpaServicePointRepository;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@EnableJpaRepositories(basePackageClasses = SpringDataJpaServicePointRepository.class)
class PostgreSQLConfiguration {

}
