package ch.sbb.backend;

import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.springframework.context.annotation.Bean;
import org.springframework.data.domain.AuditorAware;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;
import org.testcontainers.containers.PostgreSQLContainer;

@TestConfiguration
@EnableJpaAuditing(auditorAwareRef = "auditorProvider")
public class TestcontainersConfiguration {

    @Bean
    @ServiceConnection
    PostgreSQLContainer<?> postgresContainer() {
        return new PostgreSQLContainer<>("postgres:latest");
    }

    @Bean
    AuditorAware<String> auditorProvider() {
        return new AuditorAwareTestImpl();
    }
}