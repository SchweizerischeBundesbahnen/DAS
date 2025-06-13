package ch.sbb.backend.admin.infrastructure.settings.model;

import ch.sbb.backend.admin.domain.settings.model.Company;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.SequenceGenerator;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity(name = "company")
public class CompanyEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "company_id_seq")
    @SequenceGenerator(name = "company_id_seq", allocationSize = 1)
    private Integer id;

    // todo: atlas will provide a mapping to the RICS code (2026 Q2)
    private String codeRics;

    // todo: remove?
    private String shortNameZis;

    public Company toCompany() {
        return new Company(codeRics, shortNameZis);
    }
}
