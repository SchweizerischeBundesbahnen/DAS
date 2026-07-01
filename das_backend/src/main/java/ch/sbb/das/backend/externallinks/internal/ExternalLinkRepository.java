package ch.sbb.das.backend.externallinks.internal;

import org.springframework.data.repository.ListCrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ExternalLinkRepository extends ListCrudRepository<ExternalLinkEntity, Integer> {

}
