package ch.sbb.sferamock.messages.services;

import ch.sbb.sferamock.adapters.sfera.model.v0201.JourneyProfile;
import ch.sbb.sferamock.adapters.sfera.model.v0201.StoppingPointDepartureDetails;
import ch.sbb.sferamock.adapters.sfera.model.v0201.TimingPointConstraints;
import ch.sbb.sferamock.messages.common.XmlDateHelper;
import ch.sbb.sferamock.messages.common.XmlHelper;
import ch.sbb.sferamock.messages.model.TrainIdentification;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.time.Duration;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.regex.Pattern;
import javax.xml.datatype.XMLGregorianCalendar;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;
import org.springframework.stereotype.Service;

@Service
public class JourneyProfileRepository implements ApplicationRunner {

    private static final String XML_RESOURCES_CLASSPATH = "classpath:static_sfera_resources/*/SFERA_JP_*.xml";
    private static final String XML_REGEX = "/([a-zA-Z0-9]+)_\\w+/SFERA_JP_([a-zA-Z0-9]+)\\.xml";
    private static final ZonedDateTime MINUS_TIMESTAMP = ZonedDateTime.of(1, 1, 1, 0, 0, 0, 0, ZoneId.of("UTC"));
    private static final ZonedDateTime PLUS_TIMESTAMP = ZonedDateTime.of(9999, 1, 1, 0, 0, 0, 0, ZoneId.of("UTC"));
    private final XmlHelper xmlHelper;

    Map<String, JourneyProfile> journeyProfiles = new HashMap<>();

    public JourneyProfileRepository(XmlHelper xmlHelper) {
        this.xmlHelper = xmlHelper;
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
        throw new RuntimeException("Operational number extraction in JP repository failed for file: " + filename);
    }

    @Override
    public void run(ApplicationArguments args) throws Exception {
        importJps();
    }

    // company and startDate is ignored
    public Optional<JourneyProfile> getJourneyProfile(TrainIdentification trainIdentification, ZonedDateTime timestamp) {
        var journeyProfile = Optional.ofNullable(journeyProfiles.get(trainIdentification.baseOperationalNumber()));
        journeyProfile = replaceDateTimes(journeyProfile, timestamp);
        return journeyProfile;
    }

    public Set<String> getAvailableJourneyProfiles() {
        return journeyProfiles.keySet();
    }

    private void importJps() throws IOException {
        PathMatchingResourcePatternResolver resolver = new PathMatchingResourcePatternResolver();
        var resources = resolver.getResources(XML_RESOURCES_CLASSPATH);
        for (var resource : resources) {
            File file = resource.getFile();
            var operationalNumber = extractOperationalNumber(file.getPath());
            try (InputStream in = new FileInputStream(file)) {
                String xmlPayload = new String(in.readAllBytes());
                var journeyProfile = xmlHelper.xmlToObject(xmlPayload);
                journeyProfiles.put(operationalNumber, (JourneyProfile) journeyProfile);
            }
        }
    }

    private Optional<JourneyProfile> replaceDateTimes(Optional<JourneyProfile> optionalJourneyProfile, ZonedDateTime startTime) {
        return optionalJourneyProfile.map(journeyProfile -> {
            var copiedJourneyProfile = xmlHelper.deepCopy(journeyProfile);
            copiedJourneyProfile.getSegmentProfileReference().forEach(segmentProfileReference ->
                segmentProfileReference.getTimingPointConstraints().forEach(timingPointConstraint -> updateTimingPointConstraint(timingPointConstraint, startTime))
            );
            return copiedJourneyProfile;
        });
    }

    private void updateTimingPointConstraint(TimingPointConstraints timingPointConstraint, ZonedDateTime startTime) {
        timingPointConstraint.setTPPlannedLatestArrivalTime(replaceDateTime(timingPointConstraint.getTPPlannedLatestArrivalTime(), startTime));
        timingPointConstraint.setTPLatestArrivalTime(replaceDateTime(timingPointConstraint.getTPLatestArrivalTime(), startTime));

        StoppingPointDepartureDetails stoppingPointDepartureDetails = timingPointConstraint.getStoppingPointDepartureDetails();
        if (stoppingPointDepartureDetails != null) {
            stoppingPointDepartureDetails.setDepartureTime(replaceDateTime(stoppingPointDepartureDetails.getDepartureTime(), startTime));
            stoppingPointDepartureDetails.setPlannedDepartureTime(replaceDateTime(stoppingPointDepartureDetails.getPlannedDepartureTime(), startTime));
        }
    }

    private XMLGregorianCalendar replaceDateTime(XMLGregorianCalendar xmlGregorianCalendar, ZonedDateTime startTime) {
        if (xmlGregorianCalendar == null) {
            return null;
        }

        if (xmlGregorianCalendar.getYear() == MINUS_TIMESTAMP.getYear()) {
            var duration = Duration.between(MINUS_TIMESTAMP, XmlDateHelper.toZonedDateTime(xmlGregorianCalendar));
            return XmlDateHelper.toGregorianCalender(startTime.minus(duration));
        }
        if (xmlGregorianCalendar.getYear() == PLUS_TIMESTAMP.getYear()) {
            var duration = Duration.between(PLUS_TIMESTAMP, XmlDateHelper.toZonedDateTime(xmlGregorianCalendar));
            return XmlDateHelper.toGregorianCalender(startTime.plus(duration));
        }
        return xmlGregorianCalendar;
    }
}
