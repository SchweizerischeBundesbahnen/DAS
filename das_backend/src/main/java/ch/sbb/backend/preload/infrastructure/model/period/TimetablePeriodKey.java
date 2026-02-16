package ch.sbb.backend.preload.infrastructure.model.period;

import com.fasterxml.jackson.annotation.JsonProperty;

public class TimetablePeriodKey {

    /**
     * Timetable period in which the master data record is valid (Required)
     */
    @JsonProperty("timetablePeriod")
    Integer timetablePeriod;

}
