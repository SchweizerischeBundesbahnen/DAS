package ch.sbb.das.backend.appversions.internal;

import org.springframework.data.repository.ListCrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface AppVersionRepository extends ListCrudRepository<AppVersionEntity, Integer> {

    boolean existsByVersionAndIdNot(String version, Integer id);
}
