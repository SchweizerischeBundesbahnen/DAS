package ch.sbb.backend.preload.infrastructure.configuration;

import java.util.Map;
import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.springframework.boot.kafka.autoconfigure.ConcurrentKafkaListenerContainerFactoryConfigurer;
import org.springframework.boot.kafka.autoconfigure.KafkaConnectionDetails;
import org.springframework.boot.kafka.autoconfigure.KafkaProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.annotation.EnableKafka;
import org.springframework.kafka.config.ConcurrentKafkaListenerContainerFactory;
import org.springframework.kafka.core.ConsumerFactory;
import org.springframework.kafka.core.DefaultKafkaConsumerFactory;

@EnableKafka
@Configuration
public class CustomKafkaConsumerConfig {

    private final KafkaProperties kafkaProperties;

    public CustomKafkaConsumerConfig(KafkaProperties kafkaProperties) {
        this.kafkaProperties = kafkaProperties;
    }

    @Bean
    public ConcurrentKafkaListenerContainerFactory<Object, Object> timetableListenerContainerFactory(
        ConcurrentKafkaListenerContainerFactoryConfigurer configurer, KafkaConnectionDetails connectionDetails) {
        Map<String, Object> props = kafkaProperties.buildConsumerProperties();

        props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, connectionDetails.getBootstrapServers());
        props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, org.apache.kafka.common.serialization.BytesDeserializer.class);
        props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, org.apache.kafka.common.serialization.BytesDeserializer.class);
        props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");

        ConsumerFactory<Object, Object> consumerFactory = new DefaultKafkaConsumerFactory<>(props);

        ConcurrentKafkaListenerContainerFactory<Object, Object> factory = new ConcurrentKafkaListenerContainerFactory<>();
        configurer.configure(factory, consumerFactory);
        return factory;
    }

}
