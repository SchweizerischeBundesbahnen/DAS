package ch.sbb.backend.admin.infrastructure.settings;

import ch.sbb.backend.admin.infrastructure.settings.model.AppVersionEntity;
import org.springframework.data.repository.ListCrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SpringDataJpaAppVersionRepository extends ListCrudRepository<AppVersionEntity, Integer> {

}
