package ch.sbb.das.backend.locations.internal;

import org.springframework.data.repository.ListCrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TafTapLocationRepository extends ListCrudRepository<TafTapLocationEntity, Integer> {

}
