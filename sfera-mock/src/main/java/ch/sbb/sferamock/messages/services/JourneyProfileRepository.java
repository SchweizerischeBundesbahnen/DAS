package ch.sbb.sferamock.messages.services;

import ch.sbb.sferamock.adapters.sfera.model.v0201.JourneyProfile;
import ch.sbb.sferamock.messages.common.XmlHelper;
import ch.sbb.sferamock.messages.model.TrainIdentification;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;
import org.springframework.stereotype.Service;

@Service
public class JourneyProfileRepository implements ApplicationRunner {

    private static final String XML_RESOURCES_CLASSPATH = "classpath:static_sfera_resources/jp/*.xml";
    private static final String XML_REGEX = "SFERA_JP_(\\d+)\\.xml";
    private final XmlHelper xmlHelper;

    Map<String, JourneyProfile> journeyProfiles = new HashMap<>();

    public JourneyProfileRepository(XmlHelper xmlHelper) {
        this.xmlHelper = xmlHelper;
    }

    @Override
    public void run(ApplicationArguments args) throws Exception {
        importJps();
    }

    public Optional<JourneyProfile> getJourneyProfile(TrainIdentification trainIdentification) {
        return Optional.ofNullable(journeyProfiles.get(trainIdentification.operationalNumber()));
    }

    private void importJps() throws IOException {
        PathMatchingResourcePatternResolver resolver = new PathMatchingResourcePatternResolver();
        var resources = resolver.getResources(XML_RESOURCES_CLASSPATH);
        for (var resource : resources) {
            File file = resource.getFile();
            var operationalNumber = extractOperationalNumber(file.getName());
            try (InputStream in = new FileInputStream(file)) {
                String xmlPayload = new String(in.readAllBytes());
                var journeyProfile = xmlHelper.xmlToObject(xmlPayload);
                journeyProfiles.put(operationalNumber, (JourneyProfile) journeyProfile);
            }
        }
    }

    public static String extractOperationalNumber(String filename) {
        Pattern pattern = Pattern.compile(XML_REGEX);
        Matcher matcher = pattern.matcher(filename);
        if (matcher.find()) {
            return matcher.group(1);
        }
        return null;
    }
}
