package ch.sbb.das.backend.features.internal;

import ch.sbb.das.backend.companies.CompanyCode;
import org.springframework.data.repository.ListCrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface RuFeatureRepository extends ListCrudRepository<RuFeatureEntity, Integer> {

    boolean existsByCompanyCodeAndKeyValue(CompanyCode companyCode, String keyValue);

    boolean existsByCompanyCodeAndKeyValueAndIdNot(CompanyCode companyCode, String keyValue, Integer id);

}
