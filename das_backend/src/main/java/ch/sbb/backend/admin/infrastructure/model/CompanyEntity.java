package ch.sbb.backend.admin.infrastructure.model;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.SequenceGenerator;

@Entity(name = "company")
public class CompanyEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "company_id_seq")
    @SequenceGenerator(name = "company_id_seq", allocationSize = 1)
    private Integer id;

    private String codeRics;

    private String shortNameZis;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getCodeRics() {
        return codeRics;
    }

    public void setCodeRics(String ricsCode) {
        this.codeRics = ricsCode;
    }

    public String getShortNameZis() {
        return shortNameZis;
    }

    public void setShortNameZis(String shortName) {
        this.shortNameZis = shortName;
    }
}
