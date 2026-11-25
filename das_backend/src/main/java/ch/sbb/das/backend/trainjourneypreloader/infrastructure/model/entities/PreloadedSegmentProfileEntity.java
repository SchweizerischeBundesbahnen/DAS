package ch.sbb.das.backend.trainjourneypreloader.infrastructure.model.entities;

import ch.sbb.das.backend.common.StringListConverter;
import jakarta.persistence.Convert;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.SequenceGenerator;
import jakarta.persistence.Table;
import java.time.OffsetDateTime;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * Index row of a Segment Profile the preloader holds. Published rows name the segment zip that carries the SP; pending rows have no zip key yet and keep the XML until it is
 * published.
 */
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

    private String zipKey;

    private String pendingXml;

    @Convert(converter = StringListConverter.class)
    private List<String> relatedLrSpIdVersions;
}
