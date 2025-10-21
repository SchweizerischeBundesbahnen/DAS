package ch.sbb.backend.preload.xml;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import javax.xml.datatype.DatatypeConstants;
import javax.xml.datatype.XMLGregorianCalendar;
import org.junit.jupiter.api.Test;

class XmlDateHelperTest {

    @Test
    void test_toGregorianCalender_withOffsetDateTime() {
        ZoneOffset winterOffset = ZoneOffset.of("+02:00");
        OffsetDateTime dateTime = OffsetDateTime.of(2025, 6, 20, 12, 30, 45, 0, winterOffset);

        XMLGregorianCalendar result = XmlDateHelper.toGregorianCalender(dateTime);

        assertThat(result.getYear()).isEqualTo(2025);
        assertThat(result.getMonth()).isEqualTo(6);
        assertThat(result.getDay()).isEqualTo(20);
        assertThat(result.getHour()).isEqualTo(10);
        assertThat(result.getMinute()).isEqualTo(30);
        assertThat(result.getSecond()).isEqualTo(45);
        assertThat(result.getMillisecond()).isEqualTo(DatatypeConstants.FIELD_UNDEFINED);
        assertThat(result.getTimezone()).isZero();
    }

    @Test
    void test_toGregorianCalender_withLocalDate() {
        LocalDate localDate = LocalDate.of(2025, 10, 13);

        XMLGregorianCalendar result = XmlDateHelper.toGregorianCalender(localDate);

        assertThat(result.getYear()).isEqualTo(2025);
        assertThat(result.getMonth()).isEqualTo(10);
        assertThat(result.getDay()).isEqualTo(13);
        assertThat(result.getHour()).isEqualTo(DatatypeConstants.FIELD_UNDEFINED);
        assertThat(result.getMinute()).isEqualTo(DatatypeConstants.FIELD_UNDEFINED);
        assertThat(result.getSecond()).isEqualTo(DatatypeConstants.FIELD_UNDEFINED);
        assertThat(result.getMillisecond()).isEqualTo(DatatypeConstants.FIELD_UNDEFINED);
        assertThat(result.getTimezone()).isEqualTo(DatatypeConstants.FIELD_UNDEFINED);
    }
}