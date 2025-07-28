package ch.sbb.backend.admin.infrastructure.settings;

import ch.sbb.backend.admin.domain.settings.CompanyRepository;
import org.springframework.stereotype.Component;

@Component
class PersistenceCompanyRepository implements CompanyRepository {

    private final SpringDataJpaCompanyRepository companyRepository;

    PersistenceCompanyRepository(SpringDataJpaCompanyRepository companyRepository) {
        this.companyRepository = companyRepository;
    }

    @Override
    public boolean existsByCodeRics(String codeRics) {
        return companyRepository.existsByCodeRics(codeRics);
    }
}
