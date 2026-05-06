package ch.sbb.das.backend.admin.infrastructure.jpa;

import jakarta.persistence.Embeddable;
import java.time.LocalDateTime;
import lombok.Getter;
import org.springframework.data.annotation.LastModifiedBy;
import org.springframework.data.annotation.LastModifiedDate;

@Getter
@Embeddable
public class Audit {

    @LastModifiedDate
    private LocalDateTime lastModifiedAt;

    @LastModifiedBy
    private String lastModifiedBy;
}
