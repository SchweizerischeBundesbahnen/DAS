package ch.sbb.backend.admin.infrastructure.settings.model;

import jakarta.persistence.Entity;
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

@Table(name = "app_version")
@Entity
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class AppVersionEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "app_version_id_seq")
    @SequenceGenerator(name = "app_version_id_seq", allocationSize = 1)
    private Integer id;
    private String version;
    private Boolean minimalVersion;
    private LocalDate expiryDate;
}
