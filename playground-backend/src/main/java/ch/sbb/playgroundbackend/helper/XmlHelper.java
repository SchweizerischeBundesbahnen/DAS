package ch.sbb.playgroundbackend.helper;

import jakarta.xml.bind.JAXBContext;
import jakarta.xml.bind.JAXBException;
import jakarta.xml.bind.Marshaller;
import jakarta.xml.bind.Unmarshaller;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.StringReader;
import java.io.StringWriter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.util.ResourceUtils;

public final class XmlHelper {

    private static final Logger log = LoggerFactory.getLogger(XmlHelper.class);

    private XmlHelper() {
    }

    public static <T> String objectToXml(T object) {
        JAXBContext jaxbContext;
        try {
            jaxbContext = JAXBContext.newInstance(object.getClass());
            Marshaller marshaller = jaxbContext.createMarshaller();
            marshaller.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, Boolean.TRUE);

            StringWriter writer = new StringWriter();
            marshaller.marshal(object, writer);
            return writer.toString();
        } catch (JAXBException e) {
            log.error("Could not map xml", e);
            throw new RuntimeException(e);
        }
    }

    public static <T> T xmlToObject(String xmlPayload, Class<T> clazz) {
        JAXBContext jaxbContext;
        try {
            jaxbContext = JAXBContext.newInstance(clazz);
            Unmarshaller unmarshaller = jaxbContext.createUnmarshaller();
            StringReader reader = new StringReader(xmlPayload);
            return clazz.cast(unmarshaller.unmarshal(reader));
        } catch (JAXBException e) {
            log.error("Could not map xml", e);
            return null;
        }
    }

    public static <T> T xmlFileToObject(String filePath, Class<T> clazz) {
        String xmlPayload;
        try {
            File file = ResourceUtils.getFile(filePath);
            InputStream in = new FileInputStream(file);
            xmlPayload = new String(in.readAllBytes());
        } catch (IOException e) {
            log.error("Could not read xml", e);
            throw new RuntimeException(e);
        }
        return xmlToObject(xmlPayload, clazz);
    }
}
