package ch.sbb.backend.admin.domain.settings;

public interface CompanyRepository {

    boolean existsByCodeRics(String codeRics);
}
