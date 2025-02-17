package ch.sbb.backend

import org.springframework.boot.test.context.TestConfiguration
import org.springframework.boot.testcontainers.service.connection.ServiceConnection
import org.springframework.context.annotation.Bean
import org.testcontainers.containers.PostgreSQLContainer

@TestConfiguration
class TestContainerConfiguration {
    @Bean
    @ServiceConnection
    fun postgreSQLContainer(): PostgreSQLContainer<*> {
        return PostgreSQLContainer("postgres:latest")
    }
}