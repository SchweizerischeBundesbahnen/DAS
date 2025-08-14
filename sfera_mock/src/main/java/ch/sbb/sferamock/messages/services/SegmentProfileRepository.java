package ch.sbb.sferamock.messages.services;

import static ch.sbb.sferamock.messages.common.XmlHelper.MAX_MESSAGE_SIZE;

import ch.sbb.sferamock.adapters.sfera.model.v0201.NSPListComplexType;
import ch.sbb.sferamock.adapters.sfera.model.v0201.SegmentProfile;
import ch.sbb.sferamock.messages.common.XmlHelper;
import ch.sbb.sferamock.messages.model.SegmentIdentification;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;
import org.springframework.stereotype.Service;

@Service
@Slf4j
public class SegmentProfileRepository implements ApplicationRunner {

    private static final String XML_RESOURCES_CLASSPATH = "classpath:static_sfera_resources/*/SFERA_SP_*.xml";
    private static final String XML_REGEX = "/([a-zA-Z0-9]+)_\\w+/SFERA_SP_(([a-zA-Z0-9]+)_\\w+)\\.xml";

    private final XmlHelper xmlHelper;
    private final LocalRegulationRepository localRegulationRepository;

    private final Map<String, SegmentProfile> segmentProfiles = new HashMap<>();

    @Value("${localregulations.train-numbers}")
    private String[] trainNumbersWithLocalRegulations;

    public SegmentProfileRepository(XmlHelper xmlHelper, LocalRegulationRepository localRegulationRepository) {
        this.xmlHelper = xmlHelper;
        this.localRegulationRepository = localRegulationRepository;
    }

    @Override
    public void run(ApplicationArguments args) throws Exception {
        importSps();
    }

    // segment version and company is ignored
    public Optional<SegmentProfile> getSegmentProfile(SegmentIdentification spId) {
        return Optional.ofNullable(segmentProfiles.get(spId.id()));
    }

    private void importSps() throws IOException {
        PathMatchingResourcePatternResolver resolver = new PathMatchingResourcePatternResolver();
        var resources = resolver.getResources(XML_RESOURCES_CLASSPATH);
        for (var resource : resources) {
            File file = resource.getFile();
            var segmentId = extractSpId(file.getPath());
            var trainNumber = extractTrainNumber(file.getPath());
            try (InputStream in = new FileInputStream(file)) {
                String xmlPayload = new String(in.readAllBytes());
                var segmentProfile = (SegmentProfile) xmlHelper.xmlToObject(xmlPayload);
                if (trainNumber != null && Arrays.asList(trainNumbersWithLocalRegulations).contains(trainNumber)) {
                    segmentProfile = appendLocalRegulations(segmentProfile);
                }
                segmentProfiles.put(segmentId, segmentProfile);
            }
        }
    }

    private String extractSpId(String filename) {
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

    private String extractTrainNumber(String filename) {
        Pattern pattern = Pattern.compile(XML_REGEX);
        Matcher matcher = pattern.matcher(filename);
        if (matcher.find()) {
            return matcher.group(1);
        }
        return null;
    }

    private SegmentProfile appendLocalRegulations(SegmentProfile segmentProfile) {
        SegmentProfile spClone = xmlHelper.deepCopy(segmentProfile);
        spClone.getSPAreas().getTAFTAPLocation().forEach(taftapLocation -> {
            List<NSPListComplexType> localRegulationNsps = localRegulationRepository.getLocalRegulations(taftapLocation.getTAFTAPLocationAbbreviation());
            taftapLocation.getTAFTAPLocationNSP().addAll(localRegulationNsps);
        });
        if (xmlHelper.toString(spClone).length() > MAX_MESSAGE_SIZE) {
            log.warn("SegmentProfile with id={} exceeds maximum message size, not appending local regulations.", segmentProfile.getSPID());
            return segmentProfile;
        }
        return spClone;
    }
}
