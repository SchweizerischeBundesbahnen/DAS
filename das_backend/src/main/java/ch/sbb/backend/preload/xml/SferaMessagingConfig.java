package ch.sbb.backend.preload.xml;

import ch.sbb.backend.preload.sfera.model.v0300.ObjectFactory;
import jakarta.xml.bind.Marshaller;
import java.util.Map;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;
import org.springframework.oxm.jaxb.Jaxb2Marshaller;

@Configuration
public class SferaMessagingConfig {

    public static final String SFERA_V3_XSD = "SFERA_v3.00.xsd";

    @Bean
    public Jaxb2Marshaller jaxb2Marshaller() {
        var marshaller = new Jaxb2Marshaller();
        marshaller.setContextPath(ObjectFactory.class.getPackageName());
        marshaller.setSchemas(new ClassPathResource(SFERA_V3_XSD));
        marshaller.setMarshallerProperties(Map.of(Marshaller.JAXB_FRAGMENT, true)); // suppress xml prolog
        return marshaller;
    }
}
