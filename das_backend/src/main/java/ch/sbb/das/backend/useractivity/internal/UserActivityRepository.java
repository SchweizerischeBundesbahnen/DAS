package ch.sbb.das.backend.useractivity.internal;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.ListCrudRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface UserActivityRepository extends ListCrudRepository<UserActivityEntity, Integer> {

    Optional<UserActivityEntity> findByOid(String oid);

    List<UserActivityEntity> findAllByLastAccessedOnBefore(LocalDate before);

    void deleteByOidIn(List<String> oids);

    /**
     * Records that the given user accessed their data on {@code today} in a single, atomic statement.
     *
     * <p>Inserts a new record for an unknown user; for an existing user it only updates the date when it is older than {@code today}, so an active user triggers at most one write per calendar day.
     * The {@code ON CONFLICT} clause also makes concurrent inserts of the same oid race-safe. Native query because upsert is Postgres-specific.
     */
    @Modifying
    @Query(value = """
        INSERT INTO user_activity (id, oid, last_accessed_on)
        VALUES (nextval('user_activity_id_seq'), :oid, :today)
        ON CONFLICT (oid) DO UPDATE
            SET last_accessed_on = :today
            WHERE user_activity.last_accessed_on < :today
        """, nativeQuery = true)
    void recordAccess(@Param("oid") String oid, @Param("today") LocalDate today);
}
