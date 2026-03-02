package ch.sbb.backend.preload.infrastructure;

import ch.sbb.backend.preload.application.model.trainidentification.OperatingPeriod;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

@Component
@Slf4j
public class TimetablePeriodRepository {

    private final ConcurrentMap<Integer, OperatingPeriod> timetablePeriods = new ConcurrentHashMap<>();

    public void add(OperatingPeriod period) {
        timetablePeriods.put(period.getYear(), period);
    }

    public Optional<OperatingPeriod> findById(int year) {
        return Optional.ofNullable(timetablePeriods.get(year));
    }
}
