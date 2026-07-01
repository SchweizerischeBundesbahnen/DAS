package ch.sbb.das.backend.locations.internal;

import ch.sbb.das.backend.common.DateTimeUtil;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import net.javacrumbs.shedlock.spring.annotation.SchedulerLock;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

@Service
@Slf4j
@RequiredArgsConstructor
public class TafTapLocationsImportService {

    private static final int YEARS_IN_FUTURE = 1;

    private final ServicePointApiClient servicePointApiClient;
    private final TafTapLocationRepository tafTapLocationRepository;
    private final TafTapLocationMapper tafTapLocationMapper;

    @Scheduled(cron = "${atlas.import-cron}")
    @SchedulerLock(name = "importLocations", lockAtLeastFor = "${shedlock.lock-at-least-for:10m}")
    public void importLocations() {
        log.info("Starting scheduled location import");
        List<TafTapLocationEntity> locations = getLocations();
        tafTapLocationRepository.deleteAll();
        tafTapLocationRepository.saveAll(locations);
        log.info("Finished location import with {} locations", locations.size());
    }

    private List<TafTapLocationEntity> getLocations() {
        return servicePointApiClient.getAll().stream()
            .map(tafTapLocationMapper::toEntityFromServicePoint)
            .filter(this::isBeforeFutureCutoff)
            .toList();
    }

    private boolean isBeforeFutureCutoff(TafTapLocationEntity tafTapLocationEntity) {
        return tafTapLocationEntity.getValidFrom().isBefore(DateTimeUtil.today().plusYears(YEARS_IN_FUTURE));
    }
}

