package ch.sbb.backend.preload.application.model.trainidentification;

import java.time.LocalDate;
import lombok.Builder;
import lombok.Getter;

@Builder
@Getter
public class TimetablePeriod {

    Integer year;

    LocalDate firstDay;

    LocalDate lastDay;

}
