package ch.sbb.sferamock;

import ch.sbb.sferamock.messages.common.Resettable;
import ch.sbb.sferamock.messages.common.XmlHelper;
import com.solacesystems.jcsmp.Topic;
import java.io.StringReader;
import java.nio.charset.StandardCharsets;
import javax.xml.transform.stream.StreamSource;
import lombok.RequiredArgsConstructor;
import lombok.val;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.stream.binder.test.InputDestination;
import org.springframework.cloud.stream.binder.test.OutputDestination;
import org.springframework.messaging.Message;
import org.springframework.messaging.support.MessageBuilder;
import org.springframework.oxm.XmlMappingException;
import org.springframework.oxm.jaxb.Jaxb2Marshaller;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class TestMessageAdapter implements Resettable {

    // message channels / timeouts
    private static final int RECEIVE_TIMEOUT_MS = 2000;

    private final InputDestination input;

    private final OutputDestination output;

    private final Jaxb2Marshaller jaxb2Marshaller;
    private final XmlHelper xmlHelper;

    @Value("${spring.cloud.stream.bindings.processB2GMessage-in-0.destination}")
    private String processB2GMessageDestination;

    private static <T> Message<T> createMessage(T payload, Topic solaceDestinationHeader) {
        return MessageBuilder
            .withPayload(payload)
            .setHeader("solace_destination", solaceDestinationHeader)
            .build();
    }

    public <T> void sendXml(T payload, Topic solaceDestinationHeader) {
        input.send(createMessage(xmlHelper.toString(payload), solaceDestinationHeader), processB2GMessageDestination);
    }

    public <T> T receiveXml(Class<T> type) {
        return extractXmlPayload(output.receive(RECEIVE_TIMEOUT_MS), type);
    }

    @Override
    public void reset() {
        output.clear();
    }

    private <T> T extractXmlPayload(Message<byte[]> message, Class<T> clazz) {
        try {
            if (message == null) {
                throw new IllegalArgumentException("Cannot extract class because the message is null");
            }
            val xmlString = new String(message.getPayload(), StandardCharsets.UTF_8);
            return (T) jaxb2Marshaller.unmarshal(new StreamSource(new StringReader(xmlString)));
        } catch (XmlMappingException e) {
            throw new IllegalArgumentException(String.format("payload cannot be unmarshalled as type %s", clazz), e);
        }
    }
}
