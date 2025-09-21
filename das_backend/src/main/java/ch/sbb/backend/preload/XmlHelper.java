package ch.sbb.backend.preload;

import jakarta.xml.bind.JAXBException;
import jakarta.xml.bind.Marshaller;
import jakarta.xml.bind.Unmarshaller;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.StringReader;
import java.io.StringWriter;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.oxm.jaxb.Jaxb2Marshaller;
import org.springframework.stereotype.Component;

@Component
public class XmlHelper {

    public static final int MAX_MESSAGE_SIZE = 10_000_000;
    private static final Logger log = LoggerFactory.getLogger(XmlHelper.class);
    private final Jaxb2Marshaller jaxb2Marshaller;

    public XmlHelper(Jaxb2Marshaller jaxb2Marshaller) {
        this.jaxb2Marshaller = jaxb2Marshaller;
    }

    public String toString(Object object) {
        try {
            StreamResult streamResult = new StreamResult(new StringWriter());
            jaxb2Marshaller.marshal(object, streamResult);
            return streamResult.getWriter().toString();
        } catch (Exception e) {
            log.warn("Exception {} while marshalling an object of {} to a xml string", e.getLocalizedMessage(), object.getClass());
            return object.toString();
        }
    }

    public Object xmlToObject(String xml) {
        return jaxb2Marshaller.unmarshal(new StreamSource(new StringReader(xml)));
    }

    public <T> T deepCopy(T original) {
        try {
            Marshaller marshaller = jaxb2Marshaller.createMarshaller();
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            marshaller.marshal(original, baos);

            Unmarshaller unmarshaller = jaxb2Marshaller.createUnmarshaller();
            ByteArrayInputStream bais = new ByteArrayInputStream(baos.toByteArray());
            return (T) unmarshaller.unmarshal(bais);
        } catch (JAXBException e) {
            throw new RuntimeException("Failed to create deep copy", e);
        }
    }
}
