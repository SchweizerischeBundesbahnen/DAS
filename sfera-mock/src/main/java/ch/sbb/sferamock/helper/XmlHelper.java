package ch.sbb.sferamock.helper;

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
import org.springframework.util.ResourceUtils;

public final class XmlHelper {

    private XmlHelper() {
    }

    public static <T> String objectToXml(T object) throws JAXBException {
        JAXBContext jaxbContext = JAXBContext.newInstance(object.getClass());
        Marshaller marshaller = jaxbContext.createMarshaller();
        marshaller.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, Boolean.TRUE);

        StringWriter writer = new StringWriter();
        marshaller.marshal(object, writer);
        return writer.toString();
    }

    public static <T> T xmlToObject(String xmlPayload, Class<T> clazz) throws JAXBException {
        JAXBContext jaxbContext = JAXBContext.newInstance(clazz);
        Unmarshaller unmarshaller = jaxbContext.createUnmarshaller();
        StringReader reader = new StringReader(xmlPayload);
        return clazz.cast(unmarshaller.unmarshal(reader));
    }

    public static <T> T xmlFileToObject(String filePath, Class<T> clazz) throws IOException, JAXBException {
        File file = ResourceUtils.getFile(filePath);
        InputStream in = new FileInputStream(file);
        String xmlPayload = new String(in.readAllBytes());
        return xmlToObject(xmlPayload, clazz);
    }
}
