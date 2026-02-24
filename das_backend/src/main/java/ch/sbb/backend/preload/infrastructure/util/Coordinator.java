package ch.sbb.backend.preload.infrastructure.util;

import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.config.KafkaListenerEndpointRegistry;
import org.springframework.kafka.listener.MessageListenerContainer;
import org.springframework.stereotype.Component;

@Slf4j
@Component
public class Coordinator {

    private final KafkaListenerEndpointRegistry registry;

    public Coordinator(KafkaListenerEndpointRegistry registry) {
        this.registry = registry;
    }

    public void startProcessing() {
        log.info("Start consuming train identifications");
        MessageListenerContainer listener = registry.getListenerContainer("consumeTrains");
        if (listener != null && !listener.isRunning()) {
            listener.start();
        }
    }
}
