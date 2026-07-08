package ch.sbb.das.backend.companies.internal;

import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import jakarta.persistence.SequenceGenerator;
import jakarta.persistence.Table;
import java.util.ArrayList;
import java.util.List;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Table(name = "tenant")
@Entity
@Getter
@Setter
@NoArgsConstructor
public class TenantEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "tenant_id_seq")
    @SequenceGenerator(name = "tenant_id_seq", allocationSize = 1)
    private Integer id;

    private String name;

    private String tenantId;

    private boolean isAdminRoleAllowed;

    @OneToMany(mappedBy = "tenant", fetch = FetchType.EAGER)
    private List<CompanyEntity> companies = new ArrayList<>();
}
