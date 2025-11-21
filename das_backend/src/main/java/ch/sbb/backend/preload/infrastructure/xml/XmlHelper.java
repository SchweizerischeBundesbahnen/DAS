package ch.sbb.backend.preload.infrastructure.xml;

import java.io.StringReader;
import java.io.StringWriter;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import lombok.extern.slf4j.Slf4j;
import org.springframework.oxm.jaxb.Jaxb2Marshaller;
import org.springframework.stereotype.Component;

@Slf4j
@Component
public class XmlHelper {

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
            log.warn("marshalling of {} failed", object.getClass(), e);
            return object.toString();
        }
    }

    public Object xmlToObject(String xml) {
        return jaxb2Marshaller.unmarshal(new StreamSource(new StringReader(xml)));
    }
}
