package ch.sbb.sferamock.messages.services;

import ch.sbb.sferamock.adapters.sfera.model.v0201.G2BEventPayload;
import ch.sbb.sferamock.messages.common.XmlHelper;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;
import org.springframework.stereotype.Service;

@Service
public class EventRepository implements ApplicationRunner {

    private static final String XML_RESOURCES_CLASSPATH = "classpath:static_sfera_resources/*/SFERA_Event_*.xml";
    private static final String TRAIN_XML_REGEX = "/([a-zA-Z0-9]+)_\\w+/SFERA_Event_([a-zA-Z0-9]+)_\\d+\\.xml";
    private static final String OFFSET_XML_REGEX = "SFERA_Event_[a-zA-Z0-9]+_(\\d+)\\.xml";
    private final XmlHelper xmlHelper;

    Map<String, List<Event>> events = new HashMap<>();

    public EventRepository(XmlHelper xmlHelper) {
        this.xmlHelper = xmlHelper;
    }

    @Override
    public void run(ApplicationArguments args) throws Exception {
        importEvents();
    }

    private void importEvents() throws IOException {
        PathMatchingResourcePatternResolver resolver = new PathMatchingResourcePatternResolver();
        var resources = resolver.getResources(XML_RESOURCES_CLASSPATH);
        for (var resource : resources) {
            File file = resource.getFile();
            var operationalNumber = extractOperationalNumber(file.getPath());
            var offsetMs = extractOffsetMs(file.getName());
            try (InputStream in = new FileInputStream(file)) {
                String xmlPayload = new String(in.readAllBytes());
                var eventPayload = xmlHelper.xmlToObject(xmlPayload);

                List<Event> trainEvents = events.get(operationalNumber);
                if (trainEvents == null) {
                    trainEvents = new ArrayList<>();
                }
                trainEvents.add(new Event(offsetMs, (G2BEventPayload) eventPayload));
                events.put(operationalNumber, trainEvents);
            }
        }
    }

    private static String extractOperationalNumber(String filename) {
        Pattern pattern = Pattern.compile(TRAIN_XML_REGEX);
        Matcher matcher = pattern.matcher(filename);
        if (matcher.find()) {
            String directoryOperationalNumber = matcher.group(1);
            String fileOperationalNumber = matcher.group(2);
            if (directoryOperationalNumber != null && directoryOperationalNumber.equals(fileOperationalNumber)) {
                return directoryOperationalNumber;
            }
        }
        throw new RuntimeException("Operational number extraction in Event repository failed for file: " + filename);
    }

    private static int extractOffsetMs(String filename) {
        Pattern pattern = Pattern.compile(OFFSET_XML_REGEX);
        Matcher matcher = pattern.matcher(filename);
        if (matcher.find()) {
            return Integer.parseInt(matcher.group(1));
        }
        throw new RuntimeException("Offset extraction in Event repository failed for file: " + filename);
    }

    public record Event(int offsetMs, G2BEventPayload payload) {

    }
}
