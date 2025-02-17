package ch.sbb.sferamock.messages.common;

import java.time.LocalDate;
import java.time.LocalDateTime;
import javax.xml.datatype.DatatypeConfigurationException;
import javax.xml.datatype.DatatypeConstants;
import javax.xml.datatype.DatatypeFactory;
import javax.xml.datatype.XMLGregorianCalendar;

public final class XmlDateHelper {

    private XmlDateHelper() {
    }

    public static XMLGregorianCalendar toGregorianCalender(LocalDateTime localDateTime) {
        try {
            return DatatypeFactory.newInstance().newXMLGregorianCalendar(
                localDateTime.getYear(), localDateTime.getMonth().getValue(), localDateTime.getDayOfMonth(),
                localDateTime.getHour(), localDateTime.getMinute(), localDateTime.getSecond(),
                DatatypeConstants.FIELD_UNDEFINED, 0);
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

    public static LocalDate toLocalDate(XMLGregorianCalendar calendar) {
        return LocalDate.of(calendar.getYear(), calendar.getMonth(), calendar.getDay());
    }
}
