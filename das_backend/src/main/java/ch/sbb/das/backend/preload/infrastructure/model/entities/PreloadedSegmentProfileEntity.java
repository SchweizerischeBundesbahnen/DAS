package ch.sbb.das.backend.preload.infrastructure.model.entities;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.OffsetDateTime;

@Entity
@Table(name = "preloaded_segment_profile")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PreloadedSegmentProfileEntity {

    @Id
    private String id;

    private OffsetDateTime lastSeen;

    private Integer file;
}
