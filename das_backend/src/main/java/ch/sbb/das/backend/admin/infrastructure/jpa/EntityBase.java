package ch.sbb.das.backend.admin.infrastructure.jpa;

import jakarta.persistence.Embedded;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.MappedSuperclass;
import java.time.LocalDateTime;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

@MappedSuperclass
@EntityListeners(AuditingEntityListener.class)
public abstract class EntityBase {

    @Embedded
    private Audit audit = new Audit();

    public LocalDateTime getLastModifiedAt() {
        return audit.getLastModifiedAt();
    }

    public String getLastModifiedBy() {
        return audit.getLastModifiedBy();
    }
}
