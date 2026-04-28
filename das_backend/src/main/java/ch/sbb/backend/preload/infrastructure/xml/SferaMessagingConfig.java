package ch.sbb.backend.preload.infrastructure.xml;

import ch.sbb.backend.preload.sfera.model.v0400.ObjectFactory;
import jakarta.xml.bind.Marshaller;
import java.util.Map;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;
import org.springframework.oxm.jaxb.Jaxb2Marshaller;

@Configuration
public class SferaMessagingConfig {

    public static final String SFERA_V4_XSD = "SFERA_4.00.xsd";

    @Bean
    public Jaxb2Marshaller jaxb2Marshaller() {
        var marshaller = new Jaxb2Marshaller();
        marshaller.setContextPath(ObjectFactory.class.getPackageName());
        marshaller.setSchemas(new ClassPathResource(SFERA_V4_XSD));
        marshaller.setMarshallerProperties(Map.of(Marshaller.JAXB_FRAGMENT, true)); // suppress xml prolog
        return marshaller;
    }
}
