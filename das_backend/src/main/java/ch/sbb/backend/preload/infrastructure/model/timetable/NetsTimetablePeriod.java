package ch.sbb.backend.preload.infrastructure.model.timetable;

import java.time.LocalDate;
import lombok.Getter;

@Getter
public class NetsTimetablePeriod {

    Integer year;

    LocalDate firstDay;

    Integer numberOfDays;

}
