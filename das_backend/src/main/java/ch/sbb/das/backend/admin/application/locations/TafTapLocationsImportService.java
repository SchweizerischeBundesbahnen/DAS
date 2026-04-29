package ch.sbb.das.backend.admin.application.locations;

import ch.sbb.das.backend.admin.domain.locations.TafTapLocation;
import ch.sbb.das.backend.admin.domain.locations.TafTapLocationRepository;
import ch.sbb.das.backend.admin.infrastructure.atlas.ServicePoint;
import ch.sbb.das.backend.admin.infrastructure.atlas.ServicePointApiClient;
import ch.sbb.das.backend.formation.domain.model.TafTapLocationReference;
import java.util.List;
import lombok.extern.slf4j.Slf4j;
import net.javacrumbs.shedlock.spring.annotation.SchedulerLock;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

@Service
@Slf4j
public class TafTapLocationsImportService {

    private final ServicePointApiClient servicePointApiClient;
    private final TafTapLocationRepository tafTapLocationRepository;

    public TafTapLocationsImportService(ServicePointApiClient servicePointApiClient, TafTapLocationRepository tafTapLocationRepository) {
        this.servicePointApiClient = servicePointApiClient;
        this.tafTapLocationRepository = tafTapLocationRepository;
    }

    private static TafTapLocationReference toLocationReference(ServicePoint.ServicePointNumber servicePointNumber) {
        String countryCodeIso = TafTapLocationReference.toCountryCodeIso(servicePointNumber.uicCountryCode());
        return new TafTapLocationReference(countryCodeIso, servicePointNumber.numberShort());
    }

    @Scheduled(cron = "${atlas.import-cron}")
    @SchedulerLock(name = "importLocations", lockAtLeastFor = "${shedlock.lock-at-least-for:10m}")
    public void importLocations() {
        log.info("Starting scheduled location import");
        List<TafTapLocation> locations = getLocations();
        tafTapLocationRepository.deleteAll();
        tafTapLocationRepository.saveAll(locations);
        log.info("Finished location import with {} locations", locations.size());
    }

    public List<TafTapLocation> getLocations() {
        return servicePointApiClient.getAll().stream()
            .map(sp -> new TafTapLocation(
                toLocationReference(sp.number()),
                sp.designationOfficial(),
                sp.abbreviation(),
                sp.validFrom(),
                sp.validTo()
            ))
            .filter(TafTapLocation::valid)
            .toList();
    }
}

