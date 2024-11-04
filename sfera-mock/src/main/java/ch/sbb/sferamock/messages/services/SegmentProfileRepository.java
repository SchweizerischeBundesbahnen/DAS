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
    private static final String XML_RESOURCES_CLASSPATH = "classpath:static_sfera_resources/sp/*.xml";
    private static final String XML_REGEX = "SFERA_SP_(\\d+_\\d+)\\.xml";

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
            var segmentId = extractSpId(file.getName());
            InputStream in = new FileInputStream(file);
            String xmlPayload = new String(in.readAllBytes());
            var segmentProfile = xmlHelper.xmlToObject(xmlPayload);
            segmentProfiles.put(segmentId, (SegmentProfile) segmentProfile);
        }
    }

    public static String extractSpId(String filename) {
        Pattern pattern = Pattern.compile(XML_REGEX);
        Matcher matcher = pattern.matcher(filename);
        if (matcher.find()) {
            return matcher.group(1);
        }
        return null;
    }
}
