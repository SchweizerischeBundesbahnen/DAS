package ch.sbb.das.backend.admin.infrastructure.jpa;

import ch.sbb.das.backend.admin.application.settings.model.request.AppVersionRequest;
import ch.sbb.das.backend.admin.application.settings.model.response.AppVersion;
import jakarta.persistence.Entity;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.SequenceGenerator;
import jakarta.persistence.Table;
import java.time.LocalDate;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

@Table(name = "app_version")
@Entity
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@EntityListeners(AuditingEntityListener.class)
public class AppVersionEntity extends EntityBase {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "app_version_id_seq")
    @SequenceGenerator(name = "app_version_id_seq", allocationSize = 1)
    private Integer id;
    private String version;
    private Boolean minimalVersion;
    private LocalDate expiryDate;

    public static AppVersionEntity from(AppVersionRequest createRequest) {
        AppVersionEntity entity = new AppVersionEntity();
        entity.setVersion(createRequest.version());
        entity.setMinimalVersion(createRequest.minimalVersion());
        entity.setExpiryDate(createRequest.expiryDate());
        return entity;
    }

    public AppVersion toAppVersion() {
        return new AppVersion(id, version, minimalVersion, expiryDate);
    }
}
