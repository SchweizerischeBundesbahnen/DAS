package ch.sbb.das.backend.useractivity;

import java.util.List;

/**
 * Tracks the last time each user (identified by {@code oid}) accessed personal data such as personal notes or user properties. This information is used to clean up data belonging to users who have
 * been inactive for a configurable amount of time.
 */
public interface UserActivityService {

    /**
     * Records that the user identified by {@code oid} accessed their personal data now.
     *
     * @param oid the object id of the user, must not be {@code null} or blank
     */
    void recordAccess(String oid);

    /**
     * Returns the oids of all users whose most recent access is older than the given number of days.
     *
     * @param olderThanDays the inactivity threshold in days
     * @return the oids considered inactive
     */
    List<String> findInactiveOids(long olderThanDays);
}
