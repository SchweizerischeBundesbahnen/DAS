package ch.sbb.das.backend.companies.internal;

import java.util.Optional;
import org.springframework.data.repository.ListCrudRepository;
import org.springframework.stereotype.Repository;

@Repository
interface TenantRepository extends ListCrudRepository<TenantEntity, Integer> {

    Optional<TenantEntity> findByTenantId(String tenantId);
}
