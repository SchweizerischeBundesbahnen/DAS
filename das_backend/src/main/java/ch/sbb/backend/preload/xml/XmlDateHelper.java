package ch.sbb.backend.preload.xml;

import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import javax.xml.datatype.DatatypeConfigurationException;
import javax.xml.datatype.DatatypeConstants;
import javax.xml.datatype.DatatypeFactory;
import javax.xml.datatype.XMLGregorianCalendar;

public final class XmlDateHelper {

    private XmlDateHelper() {
    }

    public static XMLGregorianCalendar toGregorianCalender(OffsetDateTime offsetDateTime) {
        try {
            OffsetDateTime zonedUtcTime = offsetDateTime.withOffsetSameInstant(ZoneOffset.UTC);
            return DatatypeFactory.newInstance().newXMLGregorianCalendar(
                zonedUtcTime.getYear(), zonedUtcTime.getMonth().getValue(), zonedUtcTime.getDayOfMonth(), zonedUtcTime.getHour(),
                zonedUtcTime.getMinute(), zonedUtcTime.getSecond(), DatatypeConstants.FIELD_UNDEFINED, 0);
        } catch (DatatypeConfigurationException e) {
            throw new RuntimeException(e);
        }
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
}
