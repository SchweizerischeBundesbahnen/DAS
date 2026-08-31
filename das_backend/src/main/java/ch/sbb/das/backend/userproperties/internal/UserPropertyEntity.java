package ch.sbb.das.backend.userproperties.internal;

import jakarta.persistence.Entity;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.SequenceGenerator;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

@Getter
@Setter
@Entity
@Table(name = "user_property")
@EntityListeners(AuditingEntityListener.class)
public class UserPropertyEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "user_property_id_seq")
    @SequenceGenerator(name = "user_property_id_seq", allocationSize = 1)
    private Integer id;

    private String oid;

    private String key;

    private String value;

    @LastModifiedDate
    private LocalDateTime lastModifiedAt;
}
