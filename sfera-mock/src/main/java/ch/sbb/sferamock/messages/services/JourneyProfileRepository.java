package ch.sbb.sferamock.messages.services;

import ch.sbb.sferamock.adapters.sfera.model.v0201.JourneyProfile;
import ch.sbb.sferamock.messages.common.XmlHelper;
import ch.sbb.sferamock.messages.model.TrainIdentification;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Service;

@Service
public class JourneyProfileRepository implements ApplicationRunner {

    private static final String XML_RESOURCES_CLASSPATH = "classpath:sfera_example_messages/";
    private final XmlHelper xmlHelper;

    Map<String, JourneyProfile> journeyProfiles = new HashMap<>();

    public JourneyProfileRepository(XmlHelper xmlHelper) {
        this.xmlHelper = xmlHelper;
    }

    @Override
    public void run(ApplicationArguments args) throws Exception {
        importJp("4816", "SFERA_JP_4816.xml");
        importJp("7839", "SFERA_JP_7839.xml");
    }

    public Optional<JourneyProfile> getJourneyProfile(TrainIdentification trainIdentification) {
        return Optional.ofNullable(journeyProfiles.get(trainIdentification.operationalNumber()));
    }

    private void importJp(String operationalNumber, String path) throws IOException {
        var journeyProfile = xmlHelper.xmlToObject(XML_RESOURCES_CLASSPATH + path);
        journeyProfiles.put(operationalNumber, (JourneyProfile) journeyProfile);
    }
}
