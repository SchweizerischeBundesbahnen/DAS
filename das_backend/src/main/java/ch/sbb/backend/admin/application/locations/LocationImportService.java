package ch.sbb.backend.admin.application.locations;

import ch.sbb.backend.admin.domain.locations.Location;
import ch.sbb.backend.admin.domain.locations.LocationRepository;
import ch.sbb.backend.admin.infrastructure.locations.AtlasServicePoint;
import ch.sbb.backend.admin.infrastructure.locations.LocationApiClient;
import ch.sbb.backend.formation.domain.model.TafTapLocationReference;
import java.util.List;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

@Service
@Slf4j
public class LocationImportService {

    private final LocationApiClient locationApiClient;
    private final LocationRepository locationRepository;

    public LocationImportService(LocationApiClient locationApiClient, LocationRepository locationRepository) {
        this.locationApiClient = locationApiClient;
        this.locationRepository = locationRepository;
    }

    @Scheduled(cron = "${atlas.import-cron}")
    public void importLocations() {
        log.info("Starting scheduled location import");
        List<Location> locations = getLocations();
        locationRepository.deleteAll();
        locationRepository.saveAll(locations);
        log.info("Finished location import");
    }

    public List<Location> getLocations() {
        return locationApiClient.getServicePoints().stream()
            .map(sp -> new Location(
                toLocationReference(sp.number()),
                sp.designationOfficial(),
                sp.abbreviation(),
                sp.validFrom(),
                sp.validTo()
            ))
            .filter(Location::valid)
            .toList();
    }

    private static TafTapLocationReference toLocationReference(AtlasServicePoint.ServicePointNumber servicePointNumber) {
        String countryCodeIso = TafTapLocationReference.toCountryCodeIso(servicePointNumber.uicCountryCode());
        return new TafTapLocationReference(countryCodeIso, servicePointNumber.numberShort());
    }
}

