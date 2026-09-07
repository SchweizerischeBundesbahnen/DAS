package ch.sbb.das.backend.useractivity.internal;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
import org.springframework.data.repository.ListCrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserActivityRepository extends ListCrudRepository<UserActivityEntity, Integer> {

    Optional<UserActivityEntity> findByOid(String oid);

    List<UserActivityEntity> findAllByLastAccessedAtBefore(OffsetDateTime before);

    void deleteByOidIn(List<String> oids);
}
