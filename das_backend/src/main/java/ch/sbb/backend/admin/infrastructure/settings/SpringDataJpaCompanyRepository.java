package ch.sbb.backend.admin.infrastructure.settings;

import ch.sbb.backend.admin.infrastructure.settings.model.CompanyEntity;
import org.springframework.data.repository.ListCrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SpringDataJpaCompanyRepository extends ListCrudRepository<CompanyEntity, Integer> {

    boolean existsByCodeRics(String codeRics);
}
