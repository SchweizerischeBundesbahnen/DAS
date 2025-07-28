package ch.sbb.backend.admin.domain.settings;

public class CompanyServiceImpl implements CompanyService {

    private final CompanyRepository companyRepository;

    public CompanyServiceImpl(CompanyRepository companyRepository) {
        this.companyRepository = companyRepository;
    }

    @Override
    public boolean existsByCodeRics(String codeRics) {
        return companyRepository.existsByCodeRics(codeRics);
    }
}
