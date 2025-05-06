package ch.sbb.backend.admin.infrastructure.servicepoint;

import ch.sbb.backend.admin.infrastructure.servicepoint.model.ServicePointEntity;
import java.util.Optional;
import org.springframework.data.repository.ListCrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SpringDataJpaServicePointRepository extends ListCrudRepository<ServicePointEntity, Integer> {

    Optional<ServicePointEntity> findByUic(int uic);
}
