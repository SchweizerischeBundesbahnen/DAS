package ch.sbb.das.backend.trainjourneypreloader.infrastructure.model.entities;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.SequenceGenerator;
import jakarta.persistence.Table;
import java.time.OffsetDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "preloaded_segment_profile")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PreloadedSegmentProfileEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "preloaded_segment_id_seq")
    @SequenceGenerator(name = "preloaded_segment_id_seq", allocationSize = 1)
    private Integer id;

    private String spIdVersion;

    private OffsetDateTime lastSeen;

    private Integer fileId;
}
