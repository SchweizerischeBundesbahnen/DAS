package ch.sbb.das.backend.admin.infrastructure.jpa;

import org.springframework.data.repository.ListCrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ExternalLinkEntityRepository extends ListCrudRepository<ExternalLinkEntity, Integer> {
}
