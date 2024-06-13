package ch.sbb.playgroundbackend.controller;

import org.springframework.cloud.stream.function.StreamBridge;
import org.springframework.integration.support.MessageBuilder;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("mq")
public class MqController {

    private final StreamBridge streamBridge;

    public MqController(StreamBridge streamBridge) {
        this.streamBridge = streamBridge;
    }

    @PostMapping
    String publish(@RequestParam String topic, @RequestParam String message) {
        streamBridge.send(topic, MessageBuilder.withPayload(message).build());
        return "Message sent to Solace topic: " + topic;
    }

}
