package ch.sbb.das.backend.userproperties.internal;

import java.util.List;
import java.util.Optional;
import org.springframework.data.repository.ListCrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserPropertyRepository extends ListCrudRepository<UserPropertyEntity, Integer> {

    List<UserPropertyEntity> findAllByOid(String oid);

    Optional<UserPropertyEntity> findByOidAndKey(String oid, String key);

    void deleteByOidAndKey(String oid, String key);
}
