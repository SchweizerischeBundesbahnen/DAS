package ch.sbb.backend.preload.infrastructure.configuration;

import java.util.Map;
import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.common.config.SaslConfigs;
import org.apache.kafka.common.security.plain.PlainLoginModule;
import org.springframework.beans.factory.annotation.Value;
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

    private static final String CONSUMER_PREFIX = "consumer.";
    private final KafkaProperties kafkaProperties;

    public CustomKafkaConsumerConfig(KafkaProperties kafkaProperties) {
        this.kafkaProperties = kafkaProperties;
    }

    @Bean
    public ConcurrentKafkaListenerContainerFactory<Object, Object> timetableListenerContainerFactory(
        ConcurrentKafkaListenerContainerFactoryConfigurer configurer, KafkaConnectionDetails connectionDetails,
        @Value("${preload.kafka.username}") String user,
        @Value("${preload.kafka.password}") String password,
        @Value("${preload.kafka.bootstrap-server}") String bootstrapUrl
    ) {
        Map<String, Object> props = kafkaProperties.buildConsumerProperties();

        props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapUrl.isBlank() ? connectionDetails.getBootstrapServers() : bootstrapUrl);
        props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, org.apache.kafka.common.serialization.BytesDeserializer.class);
        props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, org.apache.kafka.common.serialization.BytesDeserializer.class);
        props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");
        props.put(SaslConfigs.SASL_JAAS_CONFIG, jaasConfig(user, password));

        ConsumerFactory<Object, Object> consumerFactory = new DefaultKafkaConsumerFactory<>(props);

        ConcurrentKafkaListenerContainerFactory<Object, Object> factory = new ConcurrentKafkaListenerContainerFactory<>();
        configurer.configure(factory, consumerFactory);
        return factory;
    }

    @Bean
    public ConcurrentKafkaListenerContainerFactory<Object, Object> trainFormationListenerContainerFactory(
        ConcurrentKafkaListenerContainerFactoryConfigurer configurer, KafkaConnectionDetails connectionDetails,
        @Value("${zis.kafka.username}") String user,
        @Value("${zis.kafka.password}") String password,
        @Value("${zis.kafka.bootstrap-server}") String bootstrapUrl
    ) {
        Map<String, Object> props = kafkaProperties.buildConsumerProperties();

        props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapUrl.isBlank() ? connectionDetails.getBootstrapServers() : bootstrapUrl);
        props.put(CONSUMER_PREFIX + ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, io.confluent.kafka.serializers.json.KafkaJsonSchemaDeserializer.class);
        props.put(CONSUMER_PREFIX + ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, io.confluent.kafka.serializers.json.KafkaJsonSchemaDeserializer.class);
        props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "latest");
        props.put(SaslConfigs.SASL_JAAS_CONFIG, jaasConfig(user, password));

        ConsumerFactory<Object, Object> consumerFactory = new DefaultKafkaConsumerFactory<>(props);

        ConcurrentKafkaListenerContainerFactory<Object, Object> factory = new ConcurrentKafkaListenerContainerFactory<>();
        configurer.configure(factory, consumerFactory);
        return factory;
    }

    private static String jaasConfig(String user, String password) {
        return String.format("%s required username=\"%s\" password=\"%s\";", PlainLoginModule.class.getName(), user, password);
    }

}
