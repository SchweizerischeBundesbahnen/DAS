package ch.sbb.sferamock.messages.common;

import ch.sbb.sferamock.adapters.sfera.model.v0300.JourneyProfile;
import ch.sbb.sferamock.adapters.sfera.model.v0300.StoppingPointDepartureDetails;
import ch.sbb.sferamock.adapters.sfera.model.v0300.TimingPointConstraints;
import java.time.Duration;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import javax.xml.datatype.DatatypeConfigurationException;
import javax.xml.datatype.DatatypeConstants;
import javax.xml.datatype.DatatypeFactory;
import javax.xml.datatype.XMLGregorianCalendar;

public final class XmlDateHelper {

    private static final ZonedDateTime MINUS_TIMESTAMP = ZonedDateTime.of(1, 1, 1, 0, 0, 0, 0, ZoneId.of("UTC"));
    private static final ZonedDateTime PLUS_TIMESTAMP = ZonedDateTime.of(9999, 1, 1, 0, 0, 0, 0, ZoneId.of("UTC"));

    private XmlDateHelper() {
    }

    public static XMLGregorianCalendar toGregorianCalender(ZonedDateTime zonedDateTime) {
        try {
            var zonedUtcTime = zonedDateTime.withZoneSameInstant(ZoneId.of("UTC"));
            return DatatypeFactory.newInstance().newXMLGregorianCalendar(
                zonedUtcTime.getYear(), zonedUtcTime.getMonth().getValue(), zonedUtcTime.getDayOfMonth(), zonedUtcTime.getHour(),
                zonedUtcTime.getMinute(), zonedUtcTime.getSecond(), DatatypeConstants.FIELD_UNDEFINED, 0);
        } catch (DatatypeConfigurationException e) {
            throw new RuntimeException(e);
        }
    }

    public static ZonedDateTime toZonedDateTime(XMLGregorianCalendar calendar) {
        return ZonedDateTime.of(calendar.getYear(), calendar.getMonth(), calendar.getDay(), calendar.getHour(),
            calendar.getMinute(), calendar.getSecond(), 0, ZoneId.of("UTC"));
    }

    public static XMLGregorianCalendar toGregorianCalender(LocalDate localDate) {
        try {
            return DatatypeFactory.newInstance().newXMLGregorianCalendarDate(
                localDate.getYear(), localDate.getMonthValue(), localDate.getDayOfMonth(),
                DatatypeConstants.FIELD_UNDEFINED);
        } catch (DatatypeConfigurationException e) {
            throw new RuntimeException(e);
        }
    }

    public static LocalDate toLocalDate(XMLGregorianCalendar calendar) {
        return LocalDate.of(calendar.getYear(), calendar.getMonth(), calendar.getDay());
    }

    public static void replaceDateTimes(JourneyProfile journeyProfile, ZonedDateTime registrationTime) {
        journeyProfile.getSegmentProfileReference().forEach(segmentProfileReference ->
            segmentProfileReference.getTimingPointConstraints().forEach(timingPointConstraint -> updateTimingPointConstraint(timingPointConstraint, registrationTime))
        );
    }

    private static void updateTimingPointConstraint(TimingPointConstraints timingPointConstraint, ZonedDateTime startTime) {
        timingPointConstraint.setTPPlannedLatestArrivalTime(replaceDateTime(timingPointConstraint.getTPPlannedLatestArrivalTime(), startTime));
        timingPointConstraint.setTPLatestArrivalTime(replaceDateTime(timingPointConstraint.getTPLatestArrivalTime(), startTime));

        StoppingPointDepartureDetails stoppingPointDepartureDetails = timingPointConstraint.getStoppingPointDepartureDetails();
        if (stoppingPointDepartureDetails != null) {
            stoppingPointDepartureDetails.setDepartureTime(replaceDateTime(stoppingPointDepartureDetails.getDepartureTime(), startTime));
            stoppingPointDepartureDetails.setPlannedDepartureTime(replaceDateTime(stoppingPointDepartureDetails.getPlannedDepartureTime(), startTime));
        }
    }

    private static XMLGregorianCalendar replaceDateTime(XMLGregorianCalendar xmlGregorianCalendar, ZonedDateTime startTime) {
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
