package ch.sbb.playgroundbackend.service;

import java.util.function.Function;
import org.springframework.cloud.stream.binder.BinderHeaders;
import org.springframework.context.annotation.Bean;
import org.springframework.messaging.Message;
import org.springframework.messaging.support.MessageBuilder;
import org.springframework.stereotype.Component;

@Component
public class MessageListener {

    @Bean
    public Function<Message<String>, Message<String>> boardToGround() {
        return message -> {
            SferaHandler sferaHandler = new SferaHandler(message.getHeaders());
            String respone = sferaHandler.boardToGround(message.getPayload());
            return MessageBuilder.withPayload(respone).setHeader(BinderHeaders.TARGET_DESTINATION, sferaHandler.replyTopic()).build();
        };
    }
}
