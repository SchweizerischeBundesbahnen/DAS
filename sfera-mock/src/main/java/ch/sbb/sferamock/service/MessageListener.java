package ch.sbb.sferamock.service;

import java.util.function.Function;
import org.springframework.cloud.stream.binder.BinderHeaders;
import org.springframework.context.annotation.Bean;
import org.springframework.messaging.Message;
import org.springframework.messaging.support.MessageBuilder;
import org.springframework.stereotype.Component;

@Component
public class MessageListener {

    @Bean
    public Function<Message<String>, Message<String>> boardToGround(SferaHandler sferaHandler) {
        return message -> {
            String respone = sferaHandler.boardToGround(message);
            if (respone == null) {
                return null;
            }
            return MessageBuilder.withPayload(respone).setHeader(BinderHeaders.TARGET_DESTINATION, sferaHandler.replyTopic).build();
        };
    }
}
