package ch.sbb.sferamock.messages.sfera;

import ch.sbb.sferamock.adapters.sfera.model.v0201.ObjectFactory;
import jakarta.xml.bind.Marshaller;
import java.util.Map;
import java.util.function.Consumer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;
import org.springframework.messaging.Message;
import org.springframework.messaging.converter.MarshallingMessageConverter;
import org.springframework.messaging.converter.MessageConverter;
import org.springframework.oxm.jaxb.Jaxb2Marshaller;

@Configuration
public class SferaMessagingConfig {

    @Bean
    public Consumer<Message<byte[]>> processB2GMessage(IncomingMessageAdapter incomingMessageAdapter) {
        return incomingMessageAdapter::processIncomingMessage;
    }

    @Bean
    public Jaxb2Marshaller jaxb2Marshaller() {
        var marshaller = new Jaxb2Marshaller();
        marshaller.setContextPath(ObjectFactory.class.getPackageName());
        marshaller.setSchemas(new ClassPathResource("SFERA_v3.00.xsd"));
        marshaller.setMarshallerProperties(Map.of(Marshaller.JAXB_FRAGMENT, true)); // suppress xml prolog
        return marshaller;
    }

    @Bean
    public MessageConverter xmlMessageConverter(Jaxb2Marshaller jaxb2Marshaller) {
        return new MarshallingMessageConverter(jaxb2Marshaller) {
            // requires subclassing, see ContentTypeConfiguration.isConverterEligible()
        };
    }

}
