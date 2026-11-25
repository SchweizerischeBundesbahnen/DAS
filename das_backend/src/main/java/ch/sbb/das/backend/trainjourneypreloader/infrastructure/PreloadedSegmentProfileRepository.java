package ch.sbb.das.backend.trainjourneypreloader.infrastructure;

import ch.sbb.das.backend.trainjourneypreloader.infrastructure.model.entities.PreloadedSegmentProfileEntity;
import jakarta.transaction.Transactional;
import java.time.OffsetDateTime;
import java.util.Collection;
import java.util.List;
import java.util.Set;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface PreloadedSegmentProfileRepository extends JpaRepository<PreloadedSegmentProfileEntity, Integer> {

    /** A row the index holds, pending or published, without its XML. */
    interface KnownSegmentProfile {

        String getSpIdVersion();

        List<String> getRelatedLrSpIdVersions();
    }

    /** A published row without its XML. */
    interface IndexedSegmentProfile {

        String getSpIdVersion();

        String getZipKey();

        OffsetDateTime getLastSeen();
    }

    /** Entry counts of one segment zip. */
    interface ZipStatistics {

        String getZipKey();

        long getEntries();

        long getStaleEntries();
    }

    List<KnownSegmentProfile> findAllBySpIdVersionIn(Set<String> ids);

    @Modifying
    @Transactional
    @Query("UPDATE PreloadedSegmentProfileEntity p SET p.lastSeen = :timestamp WHERE p.spIdVersion IN :ids")
    void updateLastSeenBySpIdVersion(@Param("timestamp") OffsetDateTime timestamp, @Param("ids") Set<String> ids);

    List<PreloadedSegmentProfileEntity> findAllByZipKeyIsNullOrderByIdAsc();

    @Query("SELECT DISTINCT p.zipKey FROM PreloadedSegmentProfileEntity p WHERE p.zipKey IS NOT NULL")
    List<String> findDistinctZipKeys();

    @Query("""
        SELECT p.zipKey AS zipKey, COUNT(p) AS entries, SUM(CASE WHEN p.lastSeen < :cutoff THEN 1 ELSE 0 END) AS staleEntries
        FROM PreloadedSegmentProfileEntity p
        WHERE p.zipKey IS NOT NULL
        GROUP BY p.zipKey""")
    List<ZipStatistics> zipStatistics(@Param("cutoff") OffsetDateTime cutoff);

    List<IndexedSegmentProfile> findAllByZipKeyIn(Collection<String> zipKeys);

    @Modifying
    @Transactional
    @Query("UPDATE PreloadedSegmentProfileEntity p SET p.zipKey = :zipKey, p.pendingXml = NULL WHERE p.spIdVersion IN :ids")
    void assignZipKey(@Param("zipKey") String zipKey, @Param("ids") Collection<String> ids);

    @Modifying
    @Transactional
    @Query("DELETE FROM PreloadedSegmentProfileEntity p WHERE p.zipKey IN :zipKeys")
    void deleteAllByZipKeyIn(@Param("zipKeys") Collection<String> zipKeys);
}
