package ch.sbb.sferamock.messages.services;

import ch.sbb.sferamock.adapters.sfera.model.v0400.OwnTrain;
import ch.sbb.sferamock.adapters.sfera.model.v0400.RelatedTrainInformation;
import ch.sbb.sferamock.adapters.sfera.model.v0400.TrainLocationInformation;
import ch.sbb.sferamock.messages.common.XmlHelper;
import ch.sbb.sferamock.messages.model.TrainIdentification;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.regex.Pattern;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;
import org.springframework.stereotype.Service;

@Service
public class RelatedTrainInformationRepository implements ApplicationRunner {

    private static final String XML_RESOURCES_CLASSPATH = "classpath:static_sfera_resources/*/SFERA_RTI_*.xml";
    private static final String XML_REGEX = "/([a-zA-Z0-9]+)_\\w+/SFERA_RTI_([a-zA-Z0-9]+)\\.xml";

    private final XmlHelper xmlHelper;

    Map<String, RelatedTrainInformation> relatedTrainInformations = new HashMap<>();

    public RelatedTrainInformationRepository(XmlHelper xmlHelper) {
        this.xmlHelper = xmlHelper;
    }

    @Override
    public void run(ApplicationArguments args) throws Exception {
        importRtis();
    }

    public RelatedTrainInformation getRelatedTrainInformation(TrainIdentification trainIdentification) {
        return Optional.ofNullable(relatedTrainInformations.get(trainIdentification.baseOperationalNumber()))
            .orElseGet(RelatedTrainInformationRepository::emptyRelatedTrainInformation);
    }

    private static String extractOperationalNumber(String filename) {
        var pattern = Pattern.compile(XML_REGEX);
        var matcher = pattern.matcher(filename);
        if (matcher.find()) {
            String directoryOperationalNumber = matcher.group(1);
            String fileOperationalNumber = matcher.group(2);
            if (directoryOperationalNumber != null && directoryOperationalNumber.equals(fileOperationalNumber)) {
                return directoryOperationalNumber;
            }
        }
        throw new RuntimeException("Operational number extraction in RelatedTrainInformation repository failed for file: " + filename);
    }

    private static RelatedTrainInformation emptyRelatedTrainInformation() {
        var relatedTrainInformation = new RelatedTrainInformation();
        var ownTrain = new OwnTrain();
        ownTrain.setTrainLocationInformation(new TrainLocationInformation());
        relatedTrainInformation.setOwnTrain(ownTrain);
        return relatedTrainInformation;
    }

    private void importRtis() throws IOException {
        PathMatchingResourcePatternResolver resolver = new PathMatchingResourcePatternResolver();
        var resources = resolver.getResources(XML_RESOURCES_CLASSPATH);
        for (var resource : resources) {
            File file = resource.getFile();
            var operationalNumber = extractOperationalNumber(file.getPath());
            try (InputStream in = new FileInputStream(file)) {
                String xmlPayload = new String(in.readAllBytes());
                var relatedTrainInformation = xmlHelper.xmlToObject(xmlPayload);
                relatedTrainInformations.put(operationalNumber, (RelatedTrainInformation) relatedTrainInformation);
            }
        }
    }
}
