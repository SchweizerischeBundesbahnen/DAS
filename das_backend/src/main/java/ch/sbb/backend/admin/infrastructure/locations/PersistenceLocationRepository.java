package ch.sbb.backend.admin.infrastructure.locations;

import ch.sbb.backend.admin.domain.locations.Location;
import ch.sbb.backend.admin.domain.locations.LocationRepository;
import java.util.List;
import org.springframework.stereotype.Component;

@Component
class PersistenceLocationRepository implements LocationRepository {

    private final SpringDataJpaLocationRepository locationRepository;

    PersistenceLocationRepository(SpringDataJpaLocationRepository locationRepository) {
        this.locationRepository = locationRepository;
    }

    @Override
    public List<Location> findAll() {
        return locationRepository.findAll().stream().map(LocationEntity::toLocation).toList();
    }

    @Override
    public void saveAll(List<Location> locations) {
        List<LocationEntity> entities = locations.stream().map(LocationEntity::from).toList();
        locationRepository.saveAll(entities);
    }

    @Override
    public void deleteAll() {
        locationRepository.deleteAll();
    }
}
