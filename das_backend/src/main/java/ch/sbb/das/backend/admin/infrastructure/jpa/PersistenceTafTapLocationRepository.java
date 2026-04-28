package ch.sbb.das.backend.admin.infrastructure.jpa;

import ch.sbb.das.backend.admin.domain.locations.TafTapLocation;
import ch.sbb.das.backend.admin.domain.locations.TafTapLocationRepository;
import java.util.List;
import org.springframework.stereotype.Component;

@Component
class PersistenceTafTapLocationRepository implements TafTapLocationRepository {

    private final SpringDataJpaTafTapLocationRepository tafTapLocationRepository;

    PersistenceTafTapLocationRepository(SpringDataJpaTafTapLocationRepository tafTapLocationRepository) {
        this.tafTapLocationRepository = tafTapLocationRepository;
    }

    @Override
    public List<TafTapLocation> findAll() {
        return tafTapLocationRepository.findAll().stream().map(LocationEntity::toLocation).toList();
    }

    @Override
    public void saveAll(List<TafTapLocation> locations) {
        List<LocationEntity> entities = locations.stream().map(LocationEntity::from).toList();
        tafTapLocationRepository.saveAll(entities);
    }

    @Override
    public void deleteAll() {
        tafTapLocationRepository.deleteAll();
    }
}
