package ch.sbb.das.backend;

import java.time.Duration;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.springframework.context.annotation.Bean;
import org.testcontainers.kafka.KafkaContainer;
import org.testcontainers.utility.DockerImageName;

@TestConfiguration
public class KafkaTestContainerConfiguration {

    private static final KafkaContainer KAFKA = new KafkaContainer(DockerImageName.parse("apache/kafka-native:4.3.1"))
        .withStartupTimeout(Duration.ofMinutes(2))
        .withStartupAttempts(3);
    
    static {
        KAFKA.start();
    }

    @Bean
    @ServiceConnection
    KafkaContainer kafkaContainer() {
        return KAFKA;
    }
}
