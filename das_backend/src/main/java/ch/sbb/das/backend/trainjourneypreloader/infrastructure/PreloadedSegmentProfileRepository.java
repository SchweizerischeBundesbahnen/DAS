package ch.sbb.das.backend.trainjourneypreloader.infrastructure;

import ch.sbb.das.backend.trainjourneypreloader.infrastructure.model.entities.PreloadedSegmentProfileEntity;
import jakarta.transaction.Transactional;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import org.springframework.data.domain.Limit;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface PreloadedSegmentProfileRepository extends JpaRepository<PreloadedSegmentProfileEntity, Integer> {

    @Modifying
    @Transactional
    @Query("UPDATE PreloadedSegmentProfileEntity p SET p.lastSeen = :timestamp WHERE p.spIdVersion IN :ids")
    void updateLastSeenBySpIdVersion(@Param("timestamp") OffsetDateTime timestamp, @Param("ids") Set<String> ids);

    List<PreloadedSegmentProfileEntity> findAllBySpIdVersionIn(Set<String> ids);

    @Query("SELECT MAX(p.fileId) FROM PreloadedSegmentProfileEntity p")
    Optional<Integer> findMaxFileId();

    int countByFileId(int file);

    int countByLastSeenBefore(OffsetDateTime cutoff);

    List<PreloadedSegmentProfileEntity> findAllByLastSeenBefore(OffsetDateTime cutoff);

    List<PreloadedSegmentProfileEntity> findAllByFileId(int file);

    List<PreloadedSegmentProfileEntity> findByLastSeenAfterOrderByFileIdDesc(OffsetDateTime cutoff, Limit limit);

}
