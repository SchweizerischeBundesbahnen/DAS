package ch.sbb.sferamock.messages.services;

import ch.sbb.sferamock.adapters.sfera.model.v0201.SegmentProfile;
import ch.sbb.sferamock.messages.common.XmlHelper;
import ch.sbb.sferamock.messages.model.SegmentIdentification;
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
public class SegmentProfileRepository implements ApplicationRunner {

    private static final String XML_RESOURCES_CLASSPATH = "classpath:static_sfera_resources/*/SFERA_SP_*.xml";
    private static final String XML_REGEX = "/([a-zA-Z0-9]+)_\\w+/SFERA_SP_(([a-zA-Z0-9]+)_\\w+)\\.xml";

    private final XmlHelper xmlHelper;

    Map<String, SegmentProfile> segmentProfiles = new HashMap<>();

    public SegmentProfileRepository(XmlHelper xmlHelper) {
        this.xmlHelper = xmlHelper;
    }

    @Override
    public void run(ApplicationArguments args) throws Exception {
        importSps();
    }

    public Optional<SegmentProfile> getSegmentProfile(SegmentIdentification spId) {
        return Optional.ofNullable(segmentProfiles.get(spId.id()));
    }

    private void importSps() throws IOException {
        PathMatchingResourcePatternResolver resolver = new PathMatchingResourcePatternResolver();
        var resources = resolver.getResources(XML_RESOURCES_CLASSPATH);
        for (var resource : resources) {
            File file = resource.getFile();
            var segmentId = extractSpId(file.getPath());
            try (InputStream in = new FileInputStream(file)) {
                String xmlPayload = new String(in.readAllBytes());
                var segmentProfile = xmlHelper.xmlToObject(xmlPayload);
                segmentProfiles.put(segmentId, (SegmentProfile) segmentProfile);
            }
        }
    }

    public static String extractSpId(String filename) {
        Pattern pattern = Pattern.compile(XML_REGEX);
        Matcher matcher = pattern.matcher(filename);
        if (matcher.find()) {
            String directoryOperationalNumber = matcher.group(1);
            String fileOperationalNumber = matcher.group(3);
            if (directoryOperationalNumber != null && directoryOperationalNumber.equals(fileOperationalNumber)) {
                return matcher.group(2);
            }
        }
        throw new RuntimeException("SP id extraction failed for file: " + filename);
    }
}
