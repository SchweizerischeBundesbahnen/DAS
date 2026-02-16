package ch.sbb.backend.preload.infrastructure.model.period;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.time.LocalDate;
import lombok.Getter;

@Getter
public class TimetablePeriodValue {

    @JsonProperty("year")
    Integer year;

    @JsonProperty("firstDay")
    LocalDate firstDay;

    @JsonProperty("numberOfDays")
    Integer numberOfDays;

}
