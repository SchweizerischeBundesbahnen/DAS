package ch.sbb.backend.servicepoints.infrastructure.configuration

import ch.sbb.backend.servicepoints.infrastructure.repositories.SpringDataJpaServicePointRepository
import org.springframework.data.jpa.repository.config.EnableJpaRepositories

@EnableJpaRepositories(basePackageClasses = [SpringDataJpaServicePointRepository::class])
class PostgreSQLConfiguration
