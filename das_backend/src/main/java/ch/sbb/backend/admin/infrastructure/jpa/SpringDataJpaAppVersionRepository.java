package ch.sbb.backend.admin.infrastructure.jpa;

import org.springframework.data.repository.ListCrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SpringDataJpaAppVersionRepository extends ListCrudRepository<AppVersionEntity, Integer> {

}
