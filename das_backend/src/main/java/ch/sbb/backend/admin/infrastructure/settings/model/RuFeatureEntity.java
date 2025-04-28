package ch.sbb.backend.admin.infrastructure.settings.model;

import ch.sbb.backend.admin.domain.settings.model.RuFeature;
import ch.sbb.backend.admin.domain.settings.model.RuFeatureName;
import jakarta.persistence.Entity;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.SequenceGenerator;
import java.time.LocalDateTime;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.annotation.LastModifiedBy;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

@Getter
@Setter
@Entity(name = "ru_feature")
@EntityListeners(AuditingEntityListener.class)
public class RuFeatureEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "ru_feature_id_seq")
    @SequenceGenerator(name = "ru_feature_id_seq", allocationSize = 1)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "company_id")
    private CompanyEntity company;

    private String name;

    private boolean enabled;

    @LastModifiedBy
    private String lastModifiedBy;

    @LastModifiedDate
    private LocalDateTime lastModifiedAt;

    public RuFeature toRuFeature() {
        return new RuFeature(company.toCompany(), RuFeatureName.valueOf(name), enabled);
    }
}
