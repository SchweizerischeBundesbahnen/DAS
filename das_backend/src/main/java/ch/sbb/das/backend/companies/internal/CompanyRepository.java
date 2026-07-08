package ch.sbb.das.backend.companies.internal;

import java.util.Optional;
import org.springframework.data.repository.ListCrudRepository;
import org.springframework.stereotype.Repository;

@Repository
interface CompanyRepository extends ListCrudRepository<CompanyEntity, Integer> {

    Optional<CompanyEntity> findByShortName(String shortName);

    boolean existsByCode(String code);

    boolean existsByCodeAndIdNot(String code, Integer id);

    boolean existsByShortName(String shortName);

    boolean existsByShortNameAndIdNot(String shortName, Integer id);

}
