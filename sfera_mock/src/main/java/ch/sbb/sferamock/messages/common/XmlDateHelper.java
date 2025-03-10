package ch.sbb.sferamock.messages.common;

import java.time.LocalDate;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import javax.xml.datatype.DatatypeConfigurationException;
import javax.xml.datatype.DatatypeConstants;
import javax.xml.datatype.DatatypeFactory;
import javax.xml.datatype.XMLGregorianCalendar;

public final class XmlDateHelper {

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
}
