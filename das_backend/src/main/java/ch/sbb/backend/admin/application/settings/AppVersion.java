package ch.sbb.backend.admin.application.settings;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import java.time.LocalDate;

@Entity
public record AppVersion(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    Long id,
    String version,
    Boolean minimalVersion,
    LocalDate expiryDate
) {

}
