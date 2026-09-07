package ch.sbb.das.backend.useractivity.internal;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.SequenceGenerator;
import jakarta.persistence.Table;
import java.time.LocalDate;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "user_activity")
public class UserActivityEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "user_activity_id_seq")
    @SequenceGenerator(name = "user_activity_id_seq", allocationSize = 1)
    private Integer id;

    @Column(nullable = false, unique = true)
    private String oid;

    @Column(nullable = false)
    private LocalDate lastAccessedOn;
}
