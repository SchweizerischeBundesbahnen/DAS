package ch.sbb.sferamock.messages.services;

import ch.sbb.sferamock.adapters.sfera.model.v0201.SegmentProfile;
import ch.sbb.sferamock.messages.common.XmlHelper;
import ch.sbb.sferamock.messages.model.SegmentIdentification;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Service;

@Service
public class SegmentProfileRepository implements ApplicationRunner {

    private static final String XML_RESOURCES_CLASSPATH = "classpath:sfera_example_messages/";
    private final XmlHelper xmlHelper;

    Map<String, SegmentProfile> segmentProfiles = new HashMap<>();

    public SegmentProfileRepository(XmlHelper xmlHelper) {
        this.xmlHelper = xmlHelper;
    }

    @Override
    public void run(ApplicationArguments args) throws Exception {
        importSp("1", "SFERA_SP_1.xml");
        importSp("2", "SFERA_SP_2.xml");
        importSp("3", "SFERA_SP_3.xml");
    }

    public Optional<SegmentProfile> getSegmentProfile(SegmentIdentification spId) {
        return Optional.ofNullable(segmentProfiles.get(spId.id()));
    }

    private void importSp(String operationalNumber, String path) throws IOException {
        var segmentProfile = xmlHelper.xmlToObject(XML_RESOURCES_CLASSPATH + path);
        segmentProfiles.put(operationalNumber, (SegmentProfile) segmentProfile);
    }
}
