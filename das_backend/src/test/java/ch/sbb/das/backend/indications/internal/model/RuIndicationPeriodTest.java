package ch.sbb.das.backend.indications.internal.model;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.util.Set;
import org.junit.jupiter.api.Test;

class RuIndicationPeriodTest {

    @Test
    void isDateRangeValid_returnsTrue_whenFromBeforeTo() {
        RuIndicationPeriod period = new RuIndicationPeriod(LocalDate.of(2026, 1, 1), LocalDate.of(2026, 1, 31), Set.of());

        assertTrue(period.isDateRangeValid());
    }

    @Test
    void isDateRangeValid_returnsFalse_whenFromAfterTo() {
        RuIndicationPeriod period = new RuIndicationPeriod(LocalDate.of(2026, 2, 1), LocalDate.of(2026, 1, 31), Set.of());

        assertFalse(period.isDateRangeValid());
    }

    @Test
    void isDateRangeValid_returnsTrue_whenFromEqualTo() {
        RuIndicationPeriod period = new RuIndicationPeriod(LocalDate.of(2026, 8, 1), LocalDate.of(2026, 8, 1), Set.of());

        assertTrue(period.isDateRangeValid());
    }

    @Test
    void isWeekdaySelectionValid_returnsFalse_forSingleDayWithWeekdays() {
        LocalDate date = LocalDate.of(2026, 3, 10);
        RuIndicationPeriod period = new RuIndicationPeriod(date, date, Set.of(DayOfWeek.TUESDAY));

        assertFalse(period.isWeekdaySelectionValid());
    }

    @Test
    void isWeekdaySelectionValid_returnsTrue_forSingleDayWithoutWeekdays() {
        LocalDate date = LocalDate.of(2026, 3, 10);
        RuIndicationPeriod period = new RuIndicationPeriod(date, date, Set.of());

        assertTrue(period.isWeekdaySelectionValid());
    }

    @Test
    void status_returnsInactive_whenPeriodStartsInFuture() {
        RuIndicationPeriod period = new RuIndicationPeriod(LocalDate.of(2026, 5, 10), LocalDate.of(2026, 5, 20), Set.of());

        assertEquals(PeriodStatus.INACTIVE, period.status(LocalDate.of(2026, 5, 1)));
    }

    @Test
    void status_returnsActive_whenDateInRange() {
        RuIndicationPeriod period = new RuIndicationPeriod(LocalDate.of(2026, 5, 10), LocalDate.of(2026, 5, 20), Set.of());

        assertEquals(PeriodStatus.ACTIVE, period.status(LocalDate.of(2026, 5, 15)));
    }

    @Test
    void status_returnsExpired_whenPeriodAlreadyEnded() {
        RuIndicationPeriod period = new RuIndicationPeriod(LocalDate.of(2026, 5, 10), LocalDate.of(2026, 5, 20), Set.of());

        assertEquals(PeriodStatus.EXPIRED, period.status(LocalDate.of(2026, 5, 25)));
    }
}
