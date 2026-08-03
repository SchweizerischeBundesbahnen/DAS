package ch.sbb.das.backend.locations.internal;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TafTapLocationRepository extends JpaRepository<TafTapLocationEntity, Integer> {

}
