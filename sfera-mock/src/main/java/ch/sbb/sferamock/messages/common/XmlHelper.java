package ch.sbb.sferamock.messages.common;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.StringReader;
import java.io.StringWriter;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.oxm.jaxb.Jaxb2Marshaller;
import org.springframework.stereotype.Component;
import org.springframework.util.ResourceUtils;

@Component
public class XmlHelper {

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

    public Object xmlToObject(String filePath) throws IOException {
        File file = ResourceUtils.getFile(filePath);
        InputStream in = new FileInputStream(file);
        String xmlPayload = new String(in.readAllBytes());
        return jaxb2Marshaller.unmarshal(new StreamSource(new StringReader(xmlPayload)));
    }
}
