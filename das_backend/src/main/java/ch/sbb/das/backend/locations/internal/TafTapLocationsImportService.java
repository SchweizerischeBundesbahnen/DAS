package ch.sbb.das.backend.locations.internal;

import ch.sbb.das.backend.common.DateTimeUtil;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;
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
        List<ServicePoint> servicePoints = mergeAdjacentDuplicates(servicePointApiClient.getAll());
        return servicePoints.stream()
            .map(tafTapLocationMapper::toEntityFromServicePoint)
            .filter(this::isBeforeFutureCutoff)
            .toList();
    }

    List<ServicePoint> mergeAdjacentDuplicates(List<ServicePoint> servicePoints) {
        return servicePoints.stream()
            .collect(Collectors.groupingBy(ServicePoint::content))
            .values().stream()
            .flatMap(group -> mergeGroup(group).stream())
            .toList();
    }

    private List<ServicePoint> mergeGroup(List<ServicePoint> group) {
        List<ServicePoint> sorted = group.stream()
            .sorted(Comparator.comparing(ServicePoint::validFrom))
            .toList();

        List<ServicePoint> merged = new ArrayList<>();
        ServicePoint current = sorted.getFirst();

        for (int i = 1; i < sorted.size(); i++) {
            ServicePoint next = sorted.get(i);
            if (current.isDirectlyFollowedBy(next)) {
                current = current.withValidTo(next.validTo());
            } else {
                merged.add(current);
                current = next;
            }
        }
        merged.add(current);
        return merged;
    }

    private boolean isBeforeFutureCutoff(TafTapLocationEntity tafTapLocationEntity) {
        return tafTapLocationEntity.getValidFrom().isBefore(DateTimeUtil.today().plusYears(YEARS_IN_FUTURE));
    }
}

