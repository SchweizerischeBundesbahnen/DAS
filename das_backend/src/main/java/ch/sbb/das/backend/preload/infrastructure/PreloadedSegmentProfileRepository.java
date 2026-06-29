package ch.sbb.das.backend.preload.infrastructure;

import ch.sbb.das.backend.preload.infrastructure.model.entities.PreloadedSegmentProfileEntity;
import jakarta.transaction.Transactional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
import java.util.Set;

@Repository
public interface PreloadedSegmentProfileRepository extends JpaRepository<PreloadedSegmentProfileEntity, String> {

    @Modifying
    @Transactional
    @Query("UPDATE PreloadedSegmentProfileEntity p SET p.lastSeen = :timestamp WHERE p.id IN :ids")
    int updateLastSeenByIds(@Param("timestamp") OffsetDateTime timestamp, @Param("ids") Set<String> ids);

    Optional<PreloadedSegmentProfileEntity> findFirstByOrderByFileDesc();

    int countByFile(int file);

    long countByLastSeenBefore(OffsetDateTime cutoff);

    List<PreloadedSegmentProfileEntity> findAllByLastSeenBefore(OffsetDateTime cutoff);

    List<PreloadedSegmentProfileEntity> findAllByFile(int file);
}
